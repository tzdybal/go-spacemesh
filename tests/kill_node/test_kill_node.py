import time
from datetime import datetime, timedelta

import pytz
from pytest_testconfig import config as testconfig
from tests import queries
from tests.pod import delete_pod
from tests.queries import current_index
from tests.test_bs import save_log_on_exit, setup_bootstrap, add_multi_clients, get_conf

GENESIS_TIME = pytz.utc.localize(datetime.utcnow() + timedelta(seconds=testconfig['genesis_delta'])).isoformat('T', 'seconds')

def test_kill_node(init_session, setup_bootstrap, save_log_on_exit):
    bs_info = setup_bootstrap.pods[0]

    cspec = get_conf(bs_info, testconfig['client'])
    cspec2 = get_conf(bs_info, testconfig['clientv2'])
    bootstrap = get_conf(bs_info, testconfig['bootstrap'])

    # del cspec.args['remote-data']
    # cspec.args['data-folder'] = ""
    # num_clients = 3

    clients = [add_multi_clients(testconfig["namespace"], bootstrap, 1, 'bootstrap'),
               add_multi_clients(testconfig["namespace"], cspec, 48, 'client')]
    to_be_killed = add_multi_clients(testconfig["namespace"], cspec2, 1, 'clientv2')[0]
    time.sleep(20)
    clients.append(to_be_killed)
    layer_avg_size = testconfig['client']['args']['layer-average-size']
    layers_per_epoch = int(testconfig['client']['args']['layers-per-epoch'])
    # check only third epoch
    epochs = 1
    last_layer = epochs * layers_per_epoch
    queries.wait_for_latest_layer(testconfig["namespace"], layers_per_epoch, 1)

    print("take pod down ++++++++++++++++++\n\n", to_be_killed )
    delete_pod(testconfig['namespace'], to_be_killed)

    queries.wait_for_latest_layer(testconfig["namespace"], last_layer + 2, layers_per_epoch)

    queries.poll_query_message(current_index, testconfig['namespace'], testconfig['namespace'], {"M": "sync done"}, expected=1)
    msg = queries.query_message(current_index, testconfig['namespace'], testconfig['namespace'], {"M": "reverted"})
    assert len(msg) > 0
    queries.assert_equal_layer_hashes(current_index, testconfig['namespace'])
