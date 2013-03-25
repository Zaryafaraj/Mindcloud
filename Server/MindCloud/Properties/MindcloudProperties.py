__author__ = 'afathali'

class Properties:

    memcached_servers = ['127.0.0.1:11211']
    memcached_max_clients = 100
    database_host = 'localhost'
    database_port = 27017
    database_name = 'mindcloud'
    accounts_collection_name = 'accounts'
    sharing_collection_name = 'sharings'
    subscribers_collection_name = 'subscribers'
    authorization_sweep_period = 30
    sharing_space_cleanup_sweep_period = 3600
    load_balancer_healtcheck_period = 5
    action_batch_size = 5
    sharing_space_servers = ['http://192.168.1.7:8001', 'http://192.168.1.7:8006']
    load_balancer_url = 'http://127.0.0.1:8003'
    my_ip_address = 'http://192.168.1.7'
