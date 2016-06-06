# Redis Cluster

Highly available Redis cluster with multiple sentinels and standbys.

_在Kubernetes上创建高可用Redis容器集群_

* 主从模式（Master－Salves）的标准Redis服务集群，原Master不可用后，使用投票机制从Slaves中产生新的Master

* 使用Sentinel多主模式（active－active）提供Redis Master发现

## Usage

Until better documentation arrives, see the `Makefile` for useful targets.

## Guide

_部署摘要_

### Install Redis

_安装Redis和Sentinel_

* Install K8s POD of Redis and Sentinel

__安装Redis＋Sentinel POD__

    [vagrant@localhost redis-cluster]$ ls
    CHANGELOG.md  CONTRIBUTING.md  DCO  _docs  glide.yaml  LICENSE  MAINTAINERS.md  Makefile  manifests  README.md  rootfs  _tests
    [vagrant@localhost redis-cluster]$ ls manifests/
    redis-master.yaml  redis-rc.yaml  redis-sentinel-rc.yaml  redis-sentinel-service.yaml

创建

    [vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig create -f manifests/redis-master.yaml 
    pod "redis-master" created

查看

    [vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get pods
    NAME                       READY     STATUS    RESTARTS   AGE
    redis-master               2/2       Running   0          10s

* Expose Sentnel service into cluster

__绑定Sentinel服务到集群网络和集群VIP（Virtual IP）__
 
    [vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig create -f manifests/redis-sentinel-service.yaml 
    service "redis-sentinel" created

查看Sentinel绑定的集群网络

    [vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get ep
    NAME             ENDPOINTS          AGE
    kubernetes       172.17.4.50:443    23d
    redis-sentinel   172.17.0.8:26379   11s

查看Sentinel绑定的集群VIP（在集群每台宿主机的IPTables表配置DNAT和Port－Forward的地址和端口）

    [vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get service
    NAME             CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
    kubernetes       10.3.0.1     <none>        443/TCP     23d
    redis-sentinel   10.3.0.206   <none>        26379/TCP   2m

* Validation of Internal cluster of Redis and Sentinel

__验证Redis和Sentinel在集群内的服务能力__

必须在集群网络（container networking，如flannel）内操作验证，以应用程序的方式验证可以采用在集群内运行run－once POD去执行命令

    [vagrant@localhost redis-cluster]$ echo -e "INFO\r\nQUIT\r\n" | curl telnet://172.17.0.8:26379
    $595
    # Server
    redis_version:2.8.23
    redis_git_sha1:00000000
    redis_git_dirty:0
    redis_build_id:ec084e4e7f0409d
    redis_mode:sentinel
    os:Linux 4.2.3-300.fc23.x86_64 x86_64
    arch_bits:64
    multiplexing_api:epoll
    gcc_version:4.9.2
    process_id:13
    run_id:16d1bf634ba98f858423ae7831c5f360aaac48d4
    tcp_port:26379
    uptime_in_seconds:126
    uptime_in_days:0
    hz:19
    lru_clock:5326259
    config_file:/data/sentinel.conf

    # Sentinel
    sentinel_masters:1
    sentinel_tilt:0
    sentinel_running_scripts:0
    sentinel_scripts_queue_length:0
    master0:name=mymaster,status=ok,address=172.17.0.8:6379,slaves=0,sentinels=1

    +OK

从Sentinel中获取当前Redis Master地址，获取Redis服务信息

    [vagrant@localhost redis-cluster]$ echo -e "INFO\r\n" | curl telnet://172.17.0.8:6379
    $2014
    # Server
    redis_version:2.8.23
    redis_git_sha1:00000000
    redis_git_dirty:0
    redis_build_id:ec084e4e7f0409d
    redis_mode:standalone
    os:Linux 4.2.3-300.fc23.x86_64 x86_64
    arch_bits:64
    multiplexing_api:epoll
    gcc_version:4.9.2
    process_id:7
    run_id:dced9b06fd296aa03164ac7ede959739a0952f2a
    tcp_port:6379
    uptime_in_seconds:237
    uptime_in_days:0
    hz:10
    lru_clock:5326369
    config_file:/redis-master/redis.conf
    
    # Clients
    connected_clients:3
    client_longest_output_list:0
    client_biggest_input_buf:1
    blocked_clients:0
    
    # Memory
    used_memory:851944
    used_memory_human:831.98K
    used_memory_rss:3706880
    used_memory_peak:867992
    used_memory_peak_human:847.65K
    used_memory_lua:36864
    mem_fragmentation_ratio:4.35
    mem_allocator:jemalloc-3.6.0
    
    # Persistence
    loading:0
    rdb_changes_since_last_save:0
    rdb_bgsave_in_progress:0
    rdb_last_save_time:1464943924
    rdb_last_bgsave_status:ok
    rdb_last_bgsave_time_sec:-1
    rdb_current_bgsave_time_sec:-1
    aof_enabled:1
    aof_rewrite_in_progress:0
    aof_rewrite_scheduled:0
    aof_last_rewrite_time_sec:-1
    aof_current_rewrite_time_sec:-1
    aof_last_bgrewrite_status:ok
    aof_last_write_status:ok
    aof_current_size:0
    aof_base_size:0
    aof_pending_rewrite:0
    aof_buffer_length:0
    aof_rewrite_buffer_length:0
    aof_pending_bio_fsync:0
    aof_delayed_fsync:0
    
    # Stats
    total_connections_received:4
    total_commands_processed:369
    instantaneous_ops_per_sec:1
    total_net_input_bytes:19207
    total_net_output_bytes:68152
    instantaneous_input_kbps:0.09
    instantaneous_output_kbps:0.09
    rejected_connections:0
    sync_full:0
    sync_partial_ok:0
    sync_partial_err:0
    expired_keys:0
    evicted_keys:0
    keyspace_hits:0
    keyspace_misses:0
    pubsub_channels:1
    pubsub_patterns:0
    latest_fork_usec:0
    
    # Replication
    role:master
    connected_slaves:0
    master_repl_offset:0
    repl_backlog_active:0
    repl_backlog_size:1048576
    repl_backlog_first_byte_offset:0
    repl_backlog_histlen:0
    
    # CPU
    used_cpu_sys:0.15
    used_cpu_user:0.18
    used_cpu_sys_children:0.00
    used_cpu_user_children:0.00
    
    # Keyspace
    
    +OK

__验证Sentinel的VIP服务__

    [vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get service
    NAME             CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
    kubernetes       10.3.0.1     <none>        443/TCP     23d
    redis-sentinel   10.3.0.206   <none>        26379/TCP   2m

查看到的是与直接通过集群网络地址方式是相同的Sentinel状态，因此可知，就算给Redis配置VIP，Sentinel也不可能知道，因为Sentnel是根据启动配置文件sentinel.conf去发现Redis主从实例。同样Redis也只能知道自己真正的ip地址，即docker上的地址

    [vagrant@localhost redis-cluster]$ echo -e "INFO\r\nQUIT\r\n" | curl telnet://10.3.0.206:26379
    $595
    # Server
    redis_version:2.8.23
    redis_git_sha1:00000000
    redis_git_dirty:0
    redis_build_id:ec084e4e7f0409d
    redis_mode:sentinel
    os:Linux 4.2.3-300.fc23.x86_64 x86_64
    arch_bits:64
    multiplexing_api:epoll
    gcc_version:4.9.2
    process_id:13
    run_id:16d1bf634ba98f858423ae7831c5f360aaac48d4
    tcp_port:26379
    uptime_in_seconds:279
    uptime_in_days:0
    hz:10
    lru_clock:5326412
    config_file:/data/sentinel.conf

    # Sentinel
    sentinel_masters:1
    sentinel_tilt:0
    sentinel_running_scripts:0
    sentinel_scripts_queue_length:0
    master0:name=mymaster,status=ok,address=172.17.0.8:6379,slaves=0,sentinels=1
    
    +OK

### HA

_实现高可用集群_

* Start Redis and Sentinel RC

__分别创建Redis和Sentinel的RC__

    [vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig create -f manifests/redis-rc.yaml 
    replicationcontroller "redis" created

    [vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig create -f manifests/redis-sentinel-rc.yaml 
    replicationcontroller "redis-sentinel" created

分别配置3个，现在的redis－master POD上运行的Redis是master， 而Sentinel则是Active－Active模式

    [vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get pods
    NAME                       READY     STATUS    RESTARTS   AGE
    redis-5t031                1/1       Running   0          1m
    redis-ewl98                1/1       Running   0          1m
    redis-master               2/2       Running   0          17m
    redis-sentinel-6kh9j       1/1       Running   0          51s
    redis-sentinel-y4tkl       1/1       Running   0          51s

    [vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get rc
    NAME             DESIRED   CURRENT   AGE
    redis            3         3         1m
    redis-sentinel   3         3         56s

    [vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get services
    NAME             CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
    kubernetes       10.3.0.1     <none>        443/TCP     23d
    redis-sentinel   10.3.0.206   <none>        26379/TCP   17m

    [vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get ep
    NAME             ENDPOINTS                                              AGE
    kubernetes       172.17.4.50:443                                        23d
    redis-sentinel   172.17.0.11:26379,172.17.0.12:26379,172.17.0.8:26379   17m

这是redis－master POD上的sentinel

    [vagrant@localhost redis-cluster]$ echo -e "INFO\r\n" | curl telnet://172.17.0.8:26379
    $595
    # Server
    redis_version:2.8.23
    redis_git_sha1:00000000
    redis_git_dirty:0
    redis_build_id:ec084e4e7f0409d
    redis_mode:sentinel
    os:Linux 4.2.3-300.fc23.x86_64 x86_64
    arch_bits:64
    multiplexing_api:epoll
    gcc_version:4.9.2
    process_id:13
    run_id:16d1bf634ba98f858423ae7831c5f360aaac48d4
    tcp_port:26379
    uptime_in_seconds:215
    uptime_in_days:0
    hz:13
    lru_clock:5326348
    config_file:/data/sentinel.conf

    # Sentinel
    sentinel_masters:1
    sentinel_tilt:0
    sentinel_running_scripts:0
    sentinel_scripts_queue_length:0
    master0:name=mymaster,status=ok,address=172.17.0.8:6379,slaves=0,sentinels=1

这是Redis主从集群上的部分内容

    [vagrant@localhost redis-cluster]$ echo -e "INFO\r\nQUIT\r\n" | curl telnet://172.17.0.8:6379

    # Replication
    role:master
    connected_slaves:2
    slave0:ip=172.17.0.9,port=6379,state=online,offset=8104,lag=0
    slave1:ip=172.17.0.10,port=6379,state=online,offset=8104,lag=1
    master_repl_offset:8104
    repl_backlog_active:1
    repl_backlog_size:1048576
    repl_backlog_first_byte_offset:2
    repl_backlog_histlen:8103

### Failover

_高可用性_

* Delete current Redis Master

__删除当前的Redis master POD__

    [vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig delete pods/redis-master
    pod "redis-master" deleted

    [vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get pod
    NAME                       READY     STATUS        RESTARTS   AGE
    redis-5t031                1/1       Running       0          11m
    redis-ewl98                1/1       Running       0          11m
    redis-master               2/2       Terminating   0          28m
    redis-sentinel-6kh9j       1/1       Running       0          11m
    redis-sentinel-y4tkl       1/1       Running       0          11m
    redis-tqn1s                1/1       Running       0          3s

    [vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get pod
    NAME                       READY     STATUS              RESTARTS   AGE
    redis-5t031                1/1       Running             0          12m
    redis-ewl98                1/1       Running             0          12m
    redis-master               2/2       Terminating         0          28m
    redis-sentinel-6kh9j       1/1       Running             0          11m
    redis-sentinel-81nsh       0/1       ContainerCreating   0          0s
    redis-sentinel-y4tkl       1/1       Running             0          11m
    redis-tqn1s                1/1       Running             0          13s

    [vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get pod
    NAME                       READY     STATUS    RESTARTS   AGE
    redis-5t031                1/1       Running   0          12m
    redis-ewl98                1/1       Running   0          12m
    redis-sentinel-6kh9j       1/1       Running   0          11m
    redis-sentinel-81nsh       1/1       Running   0          18s
    redis-sentinel-y4tkl       1/1       Running   0          11m
    redis-tqn1s                1/1       Running   0          31s

__透过Sentinel去发现新的Redis Master__

    [vagrant@localhost redis-cluster]$ echo -e "INFO\r\nQUIT\r\n" | curl telnet://10.3.0.206:26379
    $594
    # Server
    redis_version:2.8.23
    redis_git_sha1:00000000
    redis_git_dirty:0
    redis_build_id:ec084e4e7f0409d
    redis_mode:sentinel
    os:Linux 4.2.3-300.fc23.x86_64 x86_64
    arch_bits:64
    multiplexing_api:epoll
    gcc_version:4.9.2
    process_id:12
    run_id:d091003b4ee4e9b2dbe188334d5a49583adf31b4
    tcp_port:26379
    uptime_in_seconds:21
    uptime_in_days:0
    hz:13
    lru_clock:5327868
    config_file:/data/sentinel.conf

    # Sentinel
    sentinel_masters:1
    sentinel_tilt:0
    sentinel_running_scripts:0
    sentinel_scripts_queue_length:0
    master0:name=mymaster,status=ok,address=172.17.0.8:6379,slaves=3,sentinels=4

    +OK

Trouble

注意，在心跳检测时间内，新的Master还未选举，Sentinel发现的是失效了的Master地址

    [vagrant@localhost redis-cluster]$ echo -e "INFO\r\nQUIT\r\n" | curl telnet://172.17.0.8:6379
    curl: (7) Failed to connect to 172.17.0.8 port 6379: 没有到主机的路由

Success

__完成__

    [vagrant@localhost redis-cluster]$ echo -e "INFO\r\nQUIT\r\n" | curl telnet://172.17.0.11:26379
    $595
    # Server
    redis_version:2.8.23
    redis_git_sha1:00000000
    redis_git_dirty:0
    redis_build_id:ec084e4e7f0409d
    redis_mode:sentinel
    os:Linux 4.2.3-300.fc23.x86_64 x86_64
    arch_bits:64
    multiplexing_api:epoll
    gcc_version:4.9.2
    process_id:12
    run_id:d11039c86fbc35cf5d4250b7e07123bd7d8b46bb
    tcp_port:26379
    uptime_in_seconds:802
    uptime_in_days:0
    hz:16
    lru_clock:5327953
    config_file:/data/sentinel.conf

    # Sentinel
    sentinel_masters:1
    sentinel_tilt:0
    sentinel_running_scripts:0
    sentinel_scripts_queue_length:0
    master0:name=mymaster,status=ok,address=172.17.0.9:6379,slaves=3,sentinels=4

    +OK

这时，新的Master已经就绪 

    [vagrant@localhost redis-cluster]$ echo -e "INFO\r\nQUIT\r\n" | curl telnet://172.17.0.9:6379
    $2152
    # Server
    redis_version:2.8.23
    redis_git_sha1:00000000
    redis_git_dirty:0
    redis_build_id:ec084e4e7f0409d
    redis_mode:standalone
    os:Linux 4.2.3-300.fc23.x86_64 x86_64
    arch_bits:64
    multiplexing_api:epoll
    gcc_version:4.9.2
    process_id:14
    run_id:0490f4bceb75a049bca32a3db27cb86c89b56887
    tcp_port:6379
    uptime_in_seconds:836
    uptime_in_days:0
    hz:10
    lru_clock:5327964
    config_file:/redis-slave/redis.conf

    # Clients
    connected_clients:7
    client_longest_output_list:0
    client_biggest_input_buf:7
    blocked_clients:0

    # Memory
    used_memory:2026720
    used_memory_human:1.93M
    used_memory_rss:3989504
    used_memory_peak:2152264
    used_memory_peak_human:2.05M
    used_memory_lua:36864
    mem_fragmentation_ratio:1.97
    mem_allocator:jemalloc-3.6.0

    # Persistence
    loading:0
    rdb_changes_since_last_save:0
    rdb_bgsave_in_progress:0
    rdb_last_save_time:1464945716
    rdb_last_bgsave_status:ok
    rdb_last_bgsave_time_sec:0
    rdb_current_bgsave_time_sec:-1
    aof_enabled:1
    aof_rewrite_in_progress:0
    aof_rewrite_scheduled:0
    aof_last_rewrite_time_sec:0
    aof_current_rewrite_time_sec:-1
    aof_last_bgrewrite_status:ok
    aof_last_write_status:ok
    aof_current_size:52
    aof_base_size:0
    aof_pending_rewrite:0
    aof_buffer_length:0
    aof_rewrite_buffer_length:0
    aof_pending_bio_fsync:0
    aof_delayed_fsync:0

    # Stats
    total_connections_received:19
    total_commands_processed:5075
    instantaneous_ops_per_sec:8
    total_net_input_bytes:348275
    total_net_output_bytes:1552119
    instantaneous_input_kbps:0.40
    instantaneous_output_kbps:3.86
    rejected_connections:0
    sync_full:2
    sync_partial_ok:0
    sync_partial_err:0
    expired_keys:0
    evicted_keys:0
    keyspace_hits:0
    keyspace_misses:0
    pubsub_channels:1
    pubsub_patterns:0
    latest_fork_usec:129

    # Replication
    role:master
    connected_slaves:2
    slave0:ip=172.17.0.10,port=6379,state=online,offset=8104,lag=0
    slave1:ip=172.17.0.13,port=6379,state=online,offset=8104,lag=1
    master_repl_offset:8104
    repl_backlog_active:1
    repl_backlog_size:1048576
    repl_backlog_first_byte_offset:2
    repl_backlog_histlen:8103

    # CPU
    used_cpu_sys:0.66
    used_cpu_user:0.68
    used_cpu_sys_children:0.00
    used_cpu_user_children:0.00

    # Keyspace

    +OK

