# ASP.NET Core (Docker) & AWS ECS

Dockerでも動くASP.NET Core6 の APIサーバと、Fargateのサンプル。

Fargateは

* プライベートサブネットで動かす
* ロードバランサ経由でアクセスする
* ECR から CodePipeline でデプロイする
    * ECRのイメージが更新されたら自動デプロイする
* GitHubのコードが更新されたら自動でビルドし、ECRにイメージをPushする
    * GitHub Actions ではなく CodeBuild を利用する

ここらへん一式揃える、揃えたい。
