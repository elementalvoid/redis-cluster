# Redis Cluster

Highly available Redis cluster with multiple sentinels and standbys.

## Usage

Until better documentation arrives, see the `Makefile` for useful targets.

### Guide

* Install Redis Service

[vagrant@localhost redis-cluster]$ ls

CHANGELOG.md  CONTRIBUTING.md  DCO  _docs  glide.yaml  LICENSE  MAINTAINERS.md  Makefile  manifests  README.md  rootfs  _tests

[vagrant@localhost redis-cluster]$ ls manifests/

redis-master.yaml  redis-rc.yaml  redis-sentinel-rc.yaml  redis-sentinel-service.yaml

[vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig create -f manifests/redis-master.yaml 

pod "redis-master" created

[vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get pods

NAME                       READY     STATUS    RESTARTS   AGE

redis-master               2/2       Running   0          10s

[vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig create -f manifests/redis-sentinel-service.yaml 

service "redis-sentinel" created

[vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get service
NAME             CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
kubernetes       10.3.0.1     <none>        443/TCP     23d
redis-sentinel   10.3.0.206   <none>        26379/TCP   2m

* Internal validation

    [vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get ep
    NAME             ENDPOINTS          AGE
    kubernetes       172.17.4.50:443    23d
    redis-sentinel   172.17.0.8:26379   11s

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

* Service validation

    [vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get service
    NAME             CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
    kubernetes       10.3.0.1     <none>        443/TCP     23d
    redis-sentinel   10.3.0.206   <none>        26379/TCP   2m

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

    [vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig create -f manifests/redis-rc.yaml 
    replicationcontroller "redis" created

    [vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig create -f manifests/redis-sentinel-rc.yaml 
    replicationcontroller "redis-sentinel" created

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

* Trouble

    [vagrant@localhost redis-cluster]$ echo -e "INFO\r\nQUIT\r\n" | curl telnet://172.17.0.8:6379
    curl: (7) Failed to connect to 172.17.0.8 port 6379: 没有到主机的路由

* 

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




[vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get pods
NAME                       READY     STATUS    RESTARTS   AGE
nc-http-1578405182-27w56   1/1       Running   0          2d
redis-5t031                1/1       Running   0          3m
redis-ewl98                1/1       Running   0          3m
redis-master               2/2       Running   0          20m
redis-sentinel-6kh9j       1/1       Running   0          3m
redis-sentinel-y4tkl       1/1       Running   0          3m


[vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get service
NAME             CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
kubernetes       10.3.0.1     <none>        443/TCP     23d
nc-http          10.3.0.15    <none>        80/TCP      23d
redis-sentinel   10.3.0.206   <none>        26379/TCP   3m
[vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get services
NAME             CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
kubernetes       10.3.0.1     <none>        443/TCP     23d
nc-http          10.3.0.15    <none>        80/TCP      23d
redis-sentinel   10.3.0.206   <none>        26379/TCP   23m
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
process_id:12
run_id:d11039c86fbc35cf5d4250b7e07123bd7d8b46bb
tcp_port:26379
uptime_in_seconds:484
uptime_in_days:0
hz:15
lru_clock:5327635
config_file:/data/sentinel.conf

# Sentinel
sentinel_masters:1
sentinel_tilt:0
sentinel_running_scripts:0
sentinel_scripts_queue_length:0
master0:name=mymaster,status=ok,address=172.17.0.8:6379,slaves=2,sentinels=3

+OK
[vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get pod
NAME                       READY     STATUS    RESTARTS   AGE
nc-http-1578405182-27w56   1/1       Running   0          2d
redis-5t031                1/1       Running   0          9m
redis-ewl98                1/1       Running   0          9m
redis-master               2/2       Running   0          26m
redis-sentinel-6kh9j       1/1       Running   0          9m
redis-sentinel-y4tkl       1/1       Running   0          9m

[vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get pod
NAME                       READY     STATUS        RESTARTS   AGE
nc-http-1578405182-27w56   1/1       Running       0          2d
redis-5t031                1/1       Running       0          11m
redis-ewl98                1/1       Running       0          11m
redis-master               2/2       Terminating   0          28m
redis-sentinel-6kh9j       1/1       Running       0          11m
redis-sentinel-y4tkl       1/1       Running       0          11m
redis-tqn1s                1/1       Running       0          9s
[vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get pod
NAME                       READY     STATUS        RESTARTS   AGE
nc-http-1578405182-27w56   1/1       Running       0          2d
redis-5t031                1/1       Running       0          12m
redis-ewl98                1/1       Running       0          12m
redis-master               2/2       Terminating   0          28m
redis-sentinel-6kh9j       1/1       Running       0          11m
redis-sentinel-81nsh       1/1       Running       0          8s
redis-sentinel-y4tkl       1/1       Running       0          11m
redis-tqn1s                1/1       Running       0          21s
[vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get pod
NAME                       READY     STATUS        RESTARTS   AGE
nc-http-1578405182-27w56   1/1       Running       0          2d
redis-5t031                1/1       Running       0          12m
redis-ewl98                1/1       Running       0          12m
redis-master               2/2       Terminating   0          28m
redis-sentinel-6kh9j       1/1       Running       0          11m
redis-sentinel-81nsh       1/1       Running       0          10s
redis-sentinel-y4tkl       1/1       Running       0          11m
redis-tqn1s                1/1       Running       0          23s
[vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get pod
NAME                       READY     STATUS        RESTARTS   AGE
nc-http-1578405182-27w56   1/1       Running       0          2d
redis-5t031                1/1       Running       0          12m
redis-ewl98                1/1       Running       0          12m
redis-master               2/2       Terminating   0          28m
redis-sentinel-6kh9j       1/1       Running       0          11m
redis-sentinel-81nsh       1/1       Running       0          14s
redis-sentinel-y4tkl       1/1       Running       0          11m
redis-tqn1s                1/1       Running       0          27s
[vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get pod
NAME                       READY     STATUS        RESTARTS   AGE
nc-http-1578405182-27w56   1/1       Running       0          2d
redis-5t031                1/1       Running       0          12m
redis-ewl98                1/1       Running       0          12m
redis-master               2/2       Terminating   0          28m
redis-sentinel-6kh9j       1/1       Running       0          11m
redis-sentinel-81nsh       1/1       Running       0          16s
redis-sentinel-y4tkl       1/1       Running       0          11m
redis-tqn1s                1/1       Running       0          29s
[vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get ep
NAME             ENDPOINTS                                               AGE
kubernetes       172.17.4.50:443                                         23d
nc-http          172.17.0.6:80                                           23d
redis-sentinel   172.17.0.11:26379,172.17.0.12:26379,172.17.0.14:26379   28m
[vagrant@localhost redis-cluster]$ echo -e "INFO\r\nQUIT\r\n" | curl telnet://172.17.0.8:26379
^C
[vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get pods
NAME                       READY     STATUS    RESTARTS   AGE
nc-http-1578405182-27w56   1/1       Running   0          2d
redis-5t031                1/1       Running   0          16m
redis-ewl98                1/1       Running   0          16m
redis-sentinel-6kh9j       1/1       Running   0          16m
redis-sentinel-81nsh       1/1       Running   0          4m
redis-sentinel-y4tkl       1/1       Running   0          16m
redis-tqn1s                1/1       Running   0          4m
[vagrant@localhost redis-cluster]$ echo -e "INFO\r\nQUIT\r\n" | curl telnet://172.17.0.9:6379
$2157
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
uptime_in_seconds:1137
uptime_in_days:0
hz:10
lru_clock:5328265
config_file:/redis-slave/redis.conf

# Clients
connected_clients:7
client_longest_output_list:0
client_biggest_input_buf:7
blocked_clients:0

# Memory
used_memory:2026864
used_memory_human:1.93M
used_memory_rss:3878912
used_memory_peak:2152264
used_memory_peak_human:2.05M
used_memory_lua:36864
mem_fragmentation_ratio:1.91
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
total_connections_received:20
total_commands_processed:7065
instantaneous_ops_per_sec:7
total_net_input_bytes:443885
total_net_output_bytes:2061365
instantaneous_input_kbps:0.29
instantaneous_output_kbps:3.46
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
slave0:ip=172.17.0.10,port=6379,state=online,offset=68214,lag=0
slave1:ip=172.17.0.13,port=6379,state=online,offset=68214,lag=0
master_repl_offset:68350
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:2
repl_backlog_histlen:68349

# CPU
used_cpu_sys:0.88
used_cpu_user:0.94
used_cpu_sys_children:0.00
used_cpu_user_children:0.00

# Keyspace

+OK
[vagrant@localhost redis-cluster]$ echo -e "INFO\r\nQUIT\r\n" | curl telnet://172.17.0.11:26379
$596
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
uptime_in_seconds:1138
uptime_in_days:0
hz:16
lru_clock:5328289
config_file:/data/sentinel.conf

# Sentinel
sentinel_masters:1
sentinel_tilt:0
sentinel_running_scripts:0
sentinel_scripts_queue_length:0
master0:name=mymaster,status=ok,address=172.17.0.9:6379,slaves=3,sentinels=4

+OK
[vagrant@localhost redis-cluster]$ echo -e "INFO\r\nQUIT\r\n" | curl telnet://172.17.0.9:6379
$2157
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
uptime_in_seconds:1171
uptime_in_days:0
hz:10
lru_clock:5328299
config_file:/redis-slave/redis.conf

# Clients
connected_clients:7
client_longest_output_list:0
client_biggest_input_buf:7
blocked_clients:0

# Memory
used_memory:2026864
used_memory_human:1.93M
used_memory_rss:3878912
used_memory_peak:2152264
used_memory_peak_human:2.05M
used_memory_lua:36864
mem_fragmentation_ratio:1.91
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
total_connections_received:21
total_commands_processed:7292
instantaneous_ops_per_sec:5
total_net_input_bytes:454868
total_net_output_bytes:2123045
instantaneous_input_kbps:0.25
instantaneous_output_kbps:0.86
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
slave0:ip=172.17.0.10,port=6379,state=online,offset=75206,lag=0
slave1:ip=172.17.0.13,port=6379,state=online,offset=75206,lag=0
master_repl_offset:75342
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:2
repl_backlog_histlen:75341

# CPU
used_cpu_sys:0.91
used_cpu_user:0.98
used_cpu_sys_children:0.00
used_cpu_user_children:0.00

# Keyspace

+OK
[vagrant@localhost redis-cluster]$ echo -e "INFO\r\nQUIT\r\n" | curl telnet://172.17.0.10:6379
$2207
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
run_id:9d953b4d804e67a6fd7d8613ed6c0df2916eb2d8
tcp_port:6379
uptime_in_seconds:1317
uptime_in_days:0
hz:10
lru_clock:5328445
config_file:/redis-slave/redis.conf

# Clients
connected_clients:8
client_longest_output_list:0
client_biggest_input_buf:7
blocked_clients:0

# Memory
used_memory:958040
used_memory_human:935.59K
used_memory_rss:3735552
used_memory_peak:1088200
used_memory_peak_human:1.04M
used_memory_lua:36864
mem_fragmentation_ratio:3.90
mem_allocator:jemalloc-3.6.0

# Persistence
loading:0
rdb_changes_since_last_save:0
rdb_bgsave_in_progress:0
rdb_last_save_time:1464945821
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
aof_current_size:0
aof_base_size:0
aof_pending_rewrite:0
aof_buffer_length:0
aof_rewrite_buffer_length:0
aof_pending_bio_fsync:0
aof_delayed_fsync:0

# Stats
total_connections_received:15
total_commands_processed:8048
instantaneous_ops_per_sec:7
total_net_input_bytes:566552
total_net_output_bytes:2485328
instantaneous_input_kbps:0.51
instantaneous_output_kbps:1.46
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
latest_fork_usec:21472

# Replication
role:slave
master_host:172.17.0.9
master_port:6379
master_link_status:up
master_last_io_seconds_ago:1
master_sync_in_progress:0
slave_repl_offset:104370
slave_priority:100
slave_read_only:1
connected_slaves:0
master_repl_offset:0
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0

# CPU
used_cpu_sys:1.03
used_cpu_user:1.09
used_cpu_sys_children:0.00
used_cpu_user_children:0.00

# Keyspace

+OK
[vagrant@localhost redis-cluster]$ echo -e "INFO\r\nQUIT\r\n" | curl telnet://172.17.0.13:6379
$2205
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
run_id:244bea0937cad704e2e95dce6b8232ec5d192872
tcp_port:6379
uptime_in_seconds:627
uptime_in_days:0
hz:10
lru_clock:5328462
config_file:/redis-slave/redis.conf

# Clients
connected_clients:8
client_longest_output_list:0
client_biggest_input_buf:7
blocked_clients:0

# Memory
used_memory:957440
used_memory_human:935.00K
used_memory_rss:3801088
used_memory_peak:1051704
used_memory_peak_human:1.00M
used_memory_lua:36864
mem_fragmentation_ratio:3.97
mem_allocator:jemalloc-3.6.0

# Persistence
loading:0
rdb_changes_since_last_save:1
rdb_bgsave_in_progress:0
rdb_last_save_time:1464945627
rdb_last_bgsave_status:ok
rdb_last_bgsave_time_sec:-1
rdb_current_bgsave_time_sec:-1
aof_enabled:1
aof_rewrite_in_progress:0
aof_rewrite_scheduled:0
aof_last_rewrite_time_sec:1
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
total_connections_received:17
total_commands_processed:3827
instantaneous_ops_per_sec:5
total_net_input_bytes:266536
total_net_output_bytes:1188179
instantaneous_input_kbps:0.30
instantaneous_output_kbps:0.79
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
latest_fork_usec:488

# Replication
role:slave
master_host:172.17.0.9
master_port:6379
master_link_status:up
master_last_io_seconds_ago:1
master_sync_in_progress:0
slave_repl_offset:107798
slave_priority:100
slave_read_only:1
connected_slaves:0
master_repl_offset:0
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0

# CPU
used_cpu_sys:0.47
used_cpu_user:0.55
used_cpu_sys_children:0.00
used_cpu_user_children:0.00

# Keyspace

+OK
[vagrant@localhost redis-cluster]$ echo -e "INFO\r\nQUIT\r\n" | curl telnet://172.17.0.11:26379
$596
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
uptime_in_seconds:4048
uptime_in_days:0
hz:19
lru_clock:5331199
config_file:/data/sentinel.conf

# Sentinel
sentinel_masters:1
sentinel_tilt:0
sentinel_running_scripts:0
sentinel_scripts_queue_length:0
master0:name=mymaster,status=ok,address=172.17.0.9:6379,slaves=3,sentinels=4

+OK
[vagrant@localhost redis-cluster]$ ls
CHANGELOG.md  CONTRIBUTING.md  DCO  _docs  glide.yaml  LICENSE  MAINTAINERS.md  Makefile  manifests  README.md  rootfs  _tests
[vagrant@localhost redis-cluster]$ vim README.md 
[vagrant@localhost redis-cluster]$ vim README.md 
[vagrant@localhost redis-cluster]$ vim README.md 
[vagrant@localhost redis-cluster]$ vim README.md 
[vagrant@localhost redis-cluster]$ echo -e "INFO\r\nQUIT\r\n" | curl telnet://172.17.0.11:26379
$596
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
uptime_in_seconds:5375
uptime_in_days:0
hz:15
lru_clock:5332526
config_file:/data/sentinel.conf

# Sentinel
sentinel_masters:1
sentinel_tilt:0
sentinel_running_scripts:0
sentinel_scripts_queue_length:0
master0:name=mymaster,status=ok,address=172.17.0.9:6379,slaves=3,sentinels=4

+OK
[vagrant@localhost redis-cluster]$ kubectl --kubeconfig=/data/src/github.com/openshift/origin/kubeconfig get service
NAME             CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
kubernetes       10.3.0.1     <none>        443/TCP     23d
nc-http          10.3.0.15    <none>        80/TCP      23d
redis-sentinel   10.3.0.206   <none>        26379/TCP   1h
[vagrant@localhost redis-cluster]$ echo -e "INFO\r\nQUIT\r\n" | curl telnet://10.3.0.206:26379
$596
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
run_id:059dedd59c11548a2676381c28c7497774511b1f
tcp_port:26379
uptime_in_seconds:5410
uptime_in_days:0
hz:19
lru_clock:5332562
config_file:/data/sentinel.conf

# Sentinel
sentinel_masters:1
sentinel_tilt:0
sentinel_running_scripts:0
sentinel_scripts_queue_length:0
master0:name=mymaster,status=ok,address=172.17.0.9:6379,slaves=3,sentinels=4

+OK
[vagrant@localhost redis-cluster]$ echo -e "INFO\r\nQUIT\r\n" | curl telnet://172.17.0.9:6379
$2163
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
uptime_in_seconds:5459
uptime_in_days:0
hz:10
lru_clock:5332587
config_file:/redis-slave/redis.conf

# Clients
connected_clients:7
client_longest_output_list:0
client_biggest_input_buf:7
blocked_clients:0

# Memory
used_memory:2065616
used_memory_human:1.97M
used_memory_rss:4132864
used_memory_peak:2152264
used_memory_peak_human:2.05M
used_memory_lua:36864
mem_fragmentation_ratio:2.00
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
total_connections_received:24
total_commands_processed:23330
instantaneous_ops_per_sec:4
total_net_input_bytes:1230441
total_net_output_bytes:6197658
instantaneous_input_kbps:0.26
instantaneous_output_kbps:0.84
rejected_connections:0
sync_full:2
sync_partial_ok:2
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
slave0:ip=172.17.0.13,port=6379,state=online,offset=561310,lag=1
slave1:ip=172.17.0.10,port=6379,state=online,offset=561310,lag=1
master_repl_offset:561310
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:2
repl_backlog_histlen:561309

# CPU
used_cpu_sys:2.73
used_cpu_user:3.19
used_cpu_sys_children:0.00
used_cpu_user_children:0.00

# Keyspace

+OK
[vagrant@localhost redis-cluster]$ echo -e "INFO\r\nQUIT\r\n" | curl telnet://172.17.0.13:6379
$2209
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
run_id:244bea0937cad704e2e95dce6b8232ec5d192872
tcp_port:6379
uptime_in_seconds:4763
uptime_in_days:0
hz:10
lru_clock:5332598
config_file:/redis-slave/redis.conf

# Clients
connected_clients:8
client_longest_output_list:0
client_biggest_input_buf:7
blocked_clients:0

# Memory
used_memory:1032264
used_memory_human:1008.07K
used_memory_rss:3788800
used_memory_peak:1051704
used_memory_peak_human:1.00M
used_memory_lua:36864
mem_fragmentation_ratio:3.67
mem_allocator:jemalloc-3.6.0

# Persistence
loading:0
rdb_changes_since_last_save:0
rdb_bgsave_in_progress:0
rdb_last_save_time:1464948312
rdb_last_bgsave_status:ok
rdb_last_bgsave_time_sec:0
rdb_current_bgsave_time_sec:-1
aof_enabled:1
aof_rewrite_in_progress:0
aof_rewrite_scheduled:0
aof_last_rewrite_time_sec:1
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
total_connections_received:18
total_commands_processed:17976
instantaneous_ops_per_sec:4
total_net_input_bytes:1276775
total_net_output_bytes:5578288
instantaneous_input_kbps:0.36
instantaneous_output_kbps:1.06
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
latest_fork_usec:254

# Replication
role:slave
master_host:172.17.0.9
master_port:6379
master_link_status:up
master_last_io_seconds_ago:0
master_sync_in_progress:0
slave_repl_offset:563500
slave_priority:100
slave_read_only:1
connected_slaves:0
master_repl_offset:0
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0

# CPU
used_cpu_sys:2.40
used_cpu_user:2.48
used_cpu_sys_children:0.00
used_cpu_user_children:0.00

# Keyspace

+OK

