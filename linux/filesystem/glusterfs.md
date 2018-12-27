# 简介

GlusterFS 是一个可扩展的分布式网络文件系统。

- 无集中式元数据服务
- 全局统一命名空间
- 采用哈希算法定位文件
- 弹性卷管理

## 基本概念

- cluster集群

  相互连接的一组服务器，他们协同工作共同完成某一个功能，对外界来说就像一台主机。

- Server / Node / Peer  节点

  单台服务器，在glusterfs中单个节点被称为peer，是运行gluster和分享“卷”的服务器。

- Trusted Storage Pool  可信的存储池

  存储服务器所组成的可信网络。

- Brick “砖块”（非正式翻译）

   glusterfs创建的存储块，是一个本地文件系统的挂载点。

- Volume 卷

  Brick组成的逻辑集合，glusterfs共享给客户端的文件系统。

  - SubVolume 分卷

    由多个Brick逻辑构成的卷，是其它卷的子卷。*。比如在`分布复制卷`中每一组复制的Brick就构成了一个复制的分卷，而这些分卷又组成了分布卷。*

- Client 客户端

  挂载glusterfs共享的Volume（卷）的主机。

# Volume卷类型

- 基本卷
  - 分布式卷(Distributed Volume)
  - 复制卷(Replicated Volume)
  - 条带卷(Striped Volumes)

- 复合卷
  - 分布式复制卷(Distributed Replicated Volume)
  - 分布式条带卷(Distributed Striped Volume)
  - 复制条带卷(Replicated Striped Volume)
  - 分布式复制条带卷(Distributed Replicated Striped Volume)



## 基本卷
### 分布式卷(Distributed Volume)
### 复制卷(Replicated Volume)
### 条带卷(Striped Volumes)
## 复合卷

### 分布式复制卷(Distributed Replicated Volume)
### 分布式条带卷(Distributed Striped Volume)
### 复制条带卷(Replicated Striped Volume)
### 分布式复制条带卷(Distributed Replicated Striped
Volume)

