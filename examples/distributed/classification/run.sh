#!/bin/bash
dnn="${dnn:-resnet50}"
nworkers="${nworkers:-4}"
rdma="${rdma:-0}"
MPIPATH=/home/esetstore/.local/openmpi-4.0.1
PY=/home/esetstore/pytorch1.4/bin/python

if [ "$rdma" = "0" ]; then
params="-mca pml ob1 -mca btl ^openib \
    -mca btl_tcp_if_include 192.168.0.1/24 \
    -x NCCL_DEBUG=INFO  \
    -x NCCL_SOCKET_IFNAME=enp136s0f0,enp137s0f0 \
    -x NCCL_IB_DISABLE=1 \
    -x HOROVOD_CACHE_CAPACITY=0"
else
params="--mca pml ob1 --mca btl openib,vader,self --mca btl_openib_allow_ib 1 \
    -mca btl_tcp_if_include ib0 \
    --mca btl_openib_want_fork_support 1 \
    -x LD_LIBRARY_PATH  \
    -x NCCL_IB_DISABLE=0 \
    -x NCCL_SOCKET_IFNAME=ib0 \
    -x NCCL_DEBUG=INFO \
    -x HOROVOD_CACHE_CAPACITY=0"
fi

$MPIPATH/bin/mpirun --oversubscribe --prefix $MPIPATH -np $nworkers -hostfile cluster${nworkers} -bind-to none -map-by slot \
    $params \
    $PY main.py --config configs/imagenet/resnet50_kfac_bs4k_4gpu.json --train_root /localdata/ILSVRC2012_dataset/train --val_root /localdata/ILSVRC2012_dataset/val --dist_init_method 10.0.0.19 --dataset ImageNet
