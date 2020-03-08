from pytest_testconfig import config as testconfig
import time

from tests import queries
from tests.pod import delete_pod_cmd
from tests.utils import get_curr_ind
from tests.setup_network import setup_mul_network


def test_kill_node(init_session, setup_mul_clients, setup_mul_network, save_log_on_exit):
    namespace = init_session
    stateful_dep = setup_mul_clients[-1]
    pods = stateful_dep.pods
    kill_node_name = pods[0]["name"]

    layers_per_epoch = int(testconfig['client']['args']['layers-per-epoch'])
    # check only third epoch
    epochs = 1
    last_layer = epochs * layers_per_epoch
    queries.wait_for_latest_layer(testconfig["namespace"], last_layer, 1)

    print(f"\n\ntake {kill_node_name} down\n\n")
    assert delete_pod_cmd(kill_node_name, namespace), "pod was not deleted"

    epochs = 2
    last_layer = epochs * layers_per_epoch
    queries.wait_for_latest_layer(testconfig["namespace"], last_layer, layers_per_epoch)

    hits = queries.get_all_msg_containing(namespace, kill_node_name, "reverted")
    assert len(hits) > 0
    current_index = get_curr_ind()
    queries.assert_equal_layer_hashes(current_index, testconfig['namespace'])
