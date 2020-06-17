package grpc

import (
	"time"

	"github.com/golang/protobuf/ptypes/empty"
	"golang.org/x/net/context"
	"google.golang.org/genproto/googleapis/rpc/code"
	"google.golang.org/genproto/googleapis/rpc/status"
	"google.golang.org/grpc"
	"google.golang.org/grpc/keepalive"

	pb "github.com/spacemeshos/api/release/go/spacemesh/v1"
	"github.com/spacemeshos/go-spacemesh/api"
	"github.com/spacemeshos/go-spacemesh/cmd"
	"github.com/spacemeshos/go-spacemesh/log"
	"github.com/spacemeshos/go-spacemesh/p2p/peers"
)

// Syncer is the API to get sync status
type Syncer interface {
	IsSynced() bool
	Start()
}

// NodeService is a grpc server providing the Spacemesh api
type NodeService struct {
	Service
	Network       api.NetworkAPI   // P2P Swarm
	Tx            TxAPI            // Mesh
	GenTime       api.GenesisTimeAPI
	PeerCounter   PeerCounter
	Syncer        Syncer
}

func (s NodeService) registerService() {
	pb.RegisterNodeServiceServer(s.Server, s)
}

var _ pb.NodeServiceServer = (*NodeService)(nil)

// NewNodeService creates a new grpc service using config data.
func NewNodeService(port int, net api.NetworkAPI, tx TxAPI, genTime api.GenesisTimeAPI, syncer Syncer) *NodeService {
	options := []grpc.ServerOption{
		// XXX: this is done to prevent routers from cleaning up our connections (e.g aws load balances..)
		// TODO: these parameters work for now but we might need to revisit or add them as configuration
		// TODO: Configure maxconns, maxconcurrentcons ..
		grpc.KeepaliveParams(keepalive.ServerParameters{
			MaxConnectionIdle:     time.Minute * 120,
			MaxConnectionAge:      time.Minute * 180,
			MaxConnectionAgeGrace: time.Minute * 10,
			Time:                  time.Minute,
			Timeout:               time.Minute * 3,
		}),
	}
	server := grpc.NewServer(options...)
	return &NodeService{
		Service: Service{
			Server:        server,
			Port:          uint(port),
		},
		Network:       net,
		Tx:            tx,
		GenTime:       genTime,
		PeerCounter:   peers.NewPeers(net, log.NewDefault("grpc")),
		Syncer:        syncer,
	}
}

// Echo returns the response for an echo api request
func (s NodeService) Echo(ctx context.Context, in *pb.EchoRequest) (*pb.EchoResponse, error) {
	return &pb.EchoResponse{Msg: &pb.SimpleString{Value: in.Msg.Value}}, nil
}

// Version returns the version of the node software as a semver string
func (s NodeService) Version(ctx context.Context, in *empty.Empty) (*pb.VersionResponse, error) {
	return &pb.VersionResponse{
		VersionString: &pb.SimpleString{Value: cmd.Version},
	}, nil
}

// Build returns the build of the node software
func (s NodeService) Build(ctx context.Context, in *empty.Empty) (*pb.BuildResponse, error) {
	return &pb.BuildResponse{
		BuildString: &pb.SimpleString{Value: cmd.Commit},
	}, nil
}

// GetNodeStatus returns a status object providing information about the connected peers, sync status,
// current and verified layer
func (s NodeService) Status(ctx context.Context, request *pb.StatusRequest) (*pb.StatusResponse, error) {
	return &pb.StatusResponse{
		Status: &pb.NodeStatus{
			ConnectedPeers: s.PeerCounter.PeerCount(),
			//MinPeers:      uint64(s.Config.P2P.SwarmConfig.RandomConnections),
			//MaxPeers:      uint64(s.Config.P2P.MaxInboundPeers + s.Config.P2P.SwarmConfig.RandomConnections),
			IsSynced:      s.Syncer.IsSynced(),
			SyncedLayer:   s.Tx.LatestLayer().Uint64(),
			TopLayer:      s.GenTime.GetCurrentLayer().Uint64(),
			VerifiedLayer: s.Tx.LatestLayerInState().Uint64(),
		},
	}, nil
}

// SyncStart requests that the node start syncing the mesh (if it isn't already syncing)
func (s NodeService) SyncStart(ctx context.Context, request *pb.SyncStartRequest) (*pb.SyncStartResponse, error) {
	s.Syncer.Start()
	return &pb.SyncStartResponse{
		Status: &status.Status{Code: int32(code.Code_OK)},
	}, nil
}

// Shutdown requests a graceful shutdown
func (s NodeService) Shutdown(ctx context.Context, request *pb.ShutdownRequest) (*pb.ShutdownResponse, error) {
	cmd.Cancel()
	return &pb.ShutdownResponse{
		Status: &status.Status{Code: int32(code.Code_OK)},
	}, nil
}

// StatusStream is a stub for a future server-side streaming RPC endpoint
func (s NodeService) StatusStream(request *pb.StatusStreamRequest, stream pb.NodeService_StatusStreamServer) error {
	return nil
}

// ErrorStream is a stub for a future server-side streaming RPC endpoint
func (s NodeService) ErrorStream(request *pb.ErrorStreamRequest, stream pb.NodeService_ErrorStreamServer) error {
	return nil
}