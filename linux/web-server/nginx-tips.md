# 错误

## 413 Request entity too large

传送过多的http请求导致，修改nginx的上传限制，例如：

`client_max_body_size 20M`