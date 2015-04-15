# elbvss

ELB Vulcand Server Synchronizer  
ELB に紐付くインスタンスの状態に応じて、Vulcand server の削除・追加を行なう。

## 環境変数

キー                                     | 設定値(例)                                 | 備考
-----------------------------------------|--------------------------------------------|----------------------
AWS\_ACCESS\_KEY\_ID                     | ...                                        |
AWS\_DEFAULT\_REGION                     | ap-northeast-1                             |
AWS\_SECRET\_ACCESS\_KEY                 | ...                                        |
ETCD\_API\_URL                           | localhost:4001                             | プロトコル(http,https)を含めない
FLEET\_API\_URL                          | http://localhost:8080                      |
LOAD\_BALANCER\_NAME                     | app-lv                                     | 同期対象の ELB 名
SYNC\_INTERVAL                           | 60                                         | 同期の間隔(秒)、デフォルト: 60

## 使い方

### Docker

```
docker run --name elbvss -e AWS_ACCESS_KEY_ID=... -e AWS_SECRET_ACCESS_KEY=... -e AWS_REGION=ap-northeast-1 \
-e LOAD_BALANCER_NAME=app-lb -e ETCD_API_URL=localhost:4001 -e FLEET_API_URL=http://localhost:8080 emanon001/elbvss
```
