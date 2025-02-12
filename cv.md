Note: available as [https://kazuki-ma.github.io/cv.html](//kazuki-ma.github.io/cv.html).

簡単な自己紹介 / About me
===============

キャリアの大部分を LINE 株式会社および LINE Digital Frontier 株式会社で、一貫してサーバーサイドエンジニア (JVM) として活動していました。（-2025/01)
現在は [Gen-AX株式会社](https://www.gen-ax.co.jp/) でサーバーサイドエンジニアとして業務を行っています。

LINE Digital Frontier 株式会社では LINE マンガのサーバーサイドエンジニア / TechLead として、[1日12億以上 (3万 Request/sec 以上) のリクエストを処理する Backend を担当（安定化）させました。](https://www.green-japan.com/premium_interviews/linedigitalfrontier/interview.html)
また、LINE マンガの広告露出制御用の Private DMP の概念浸透と実装を行い、広告露出制御の基盤を構築しました。

Coding をする以外にも、チームを Lead / Motivate して開発プロセスの改善等も行い、[PR のマージまでの時間を 89 % 減少させるなどの実績もあります。](https://linedevday.linecorp.com/2020/ja/sessions/6992/)

所属するチーム (Unity 利用）で git-lfs filesize が大きくなったため [git lfs dedup](https://man.archlinux.org/man/extra/git-lfs/git-lfs-dedup.1.en) 機能を[提案し、実装](https://github.com/git-lfs/git-lfs/pull/3753)したり、[spring-boot-gradle-plugin が monorepo 環境化で遅いので高速化したり](https://github.com/spring-gradle-plugins/dependency-management-plugin/pull/289) もしました。


履歴 / Chronological history
==============

* `2025-02 - Now` / [Gen-AX（ジェナックス）株式会社](https://www.gen-ax.co.jp/). Senior software engineer. (Backend)
* `2023-04 - 2025-01` / LINE Digital Frontier. Server side senior software engineer and tech lead. - LINE Digital Frontier 株式会社。サーバーサイドシニアエンジニア、TechLead
* `2019-11 - 2022-03` / LINE Corporation. Server side senior software engineer. - LINE 株式会社（現 LINEヤフー株式会社）。サーバーサイドシニアエンジニア
* `2018-10 - 2019-10` / [Cluster, Inc](https://corp.cluster.mu/). Server side engineer of VR App and facility engineer etc. 
* `2015-03 - 2018-09` / LINE Corporation. Server side senior software engineer. Manager.
* `2013-02 - 2015-03` / Just Systems.
* `2012-04 - 2013-01` / Sony Global Solutions.
* `2010-04 - 2012-03` / Studied Information science at Nara Institute of Science and Technology. (Master of Engineering)
* `2006-04 - 2010-03` / Studied Science at Kyoto University.

[//www.facebook.com/matsuda.kazuki/about_work_and_education](https://www.facebook.com/matsuda.kazuki/about_work_and_education)


資格 / Certifications
===============
* 修士（工学） - 奈良先端科学技術大学院情報処理学専攻
* IPA - ネットワークスペシャリスト
* IPA - データベーススペシャリスト
* IPA - 情報セキュリティスペシャリスト / 情報処理安全確保支援士
* IPA - システムアーキテクト
* Microsoft Certified System Administrator
* etc.

技術スタック / Technical Stack
===============

Programming Languages
---------------------
* Java, Kotlin - 問題無く書けます
    * Maintener of [LINE BOT SDK Java](https://github.com/line/line-bot-sdk-java)
    * Memory (GC) Issue があっても、適切なプロファイリング・ヒープダンプ分析をして修正できる。
    * 意図しない CPU 消費も、必要があればプロファイリング（FlameGraph）から始まる修正などが可能。
* C++ (?)
    * 少しですが、CPU 利用効率を考慮した記述ができます。（した）

> ![img.png](https://qiita-user-contents.imgix.net/https%3A%2F%2Fqiita-image-store.s3.amazonaws.com%2F0%2F31158%2Fac9236a5-f561-7d32-45ae-efa952848497.png?ixlib=rb-4.0.0&auto=format&gif-q=60&q=75&w=1400&fit=max&s=a7fea5b731cff4f10326b94cf180c23a)
> 
> cv::Mat::forEachを使った高速なピクセル操作
> [https://qiita.com/dandelion1124/items/94542d8cd7b3455e82a0](//qiita.com/dandelion1124/items/94542d8cd7b3455e82a0)

> > Note that using forEach made the code about five times faster than using Naive Pixel Access or Pointer Arithmetic method.
>
> Parallel Pixel Access in OpenCV using forEach
> [https://learnopencv.com/parallel-pixel-access-in-opencv-using-foreach/](//learnopencv.com/parallel-pixel-access-in-opencv-using-foreach/)


とはいえメモリ管理を自分で行わなければならない言語を Production 運用する気にはなれなくなりました。
(GC 付きの言語が好きで、それ以外でも Rust が気になっています。)

* Go
  * Cluster, Inc. で 1年プロダクション環境で利用。
  * "[Writing An Interpreter In Go](https://interpreterbook.com/)" を邦訳（『[Go言語でつくるインタプリタ - O'Reilly](https://www.oreilly.co.jp/books/9784873118222/)』）が出る前に一通り読んで写経しました。

* Kubernetes Manifest - 所属企業社内ツールおよび一部本番環境でも利用したことがあり、一通りの運用（Manifest 記述とオペレーション）が可能。
* HTML, CSS, JavaScript (+AltX) - Server Side
* etc.etc...

Storage
-------
* MySQL
  * Clustered Index を考慮した大規模テーブル設計の実施やレビューが可能です。
* Redis
  * シンプルな Key Value Store としてのみ利用、Pub/Sub 利用経験はありませんが、必要に応じて実装可能です。
  * Remote Cache (Redis) と Local Cache を利用した Multi tier cache の導入（実装）を行いました。
* Elasticsearch
  * 導入（self install) 経験有り。基本は as a Service 版を利用するが、Index 設計が可能。

Others
------
* Monitoring
  * Grafana, Prometheus
    * 既存の Exporter が出力した Metrics の可視化・アラート設定はもちろん、
      必要に応じてアプリケーションの要所に Gauge / DistributionSummary を実装することも可能です。
* gRPT, Thrift
  * Server 間通信で利用経験あり。（Server <-> App 無し、Server <-> Frontend 多少）
* ProtocolBuffers (protobuf)
  * gRPC で多少の利用経験がある以外に、Redis 等での Serialization Format として日常的に利用。
* Kubernetes
  * Manifest 記述、運用経験あり。
* Git
  * Trunk Based Development への移行、Branching Model の改善などを実施。
  * git-lfs dedup 機能の提案・実装。 - https://github.com/git-lfs/git-lfs/pull/3753


職歴 / Work history
===============

2022/04- Now [LINE Digital Frontier Corporation.](https://ldfcorp.com/)
------------
* TechLead.
* Work example) Cache optimization : Introduce multi layer cache system for reducing Redis' hot key problem.
    * [1日12億以上のリクエストを処理！ LINEマンガだからできる「SREエンジニア」の仕事](https://www.green-japan.com/premium_interviews/linedigitalfrontier/interview.html) (AD)
* [Kotlin Fest 2022](https://2022.kotlinfest.dev/) Speaker (Based on CpF; 採択率?)

> <iframe class="speakerdeck-iframe" frameborder="0" src="https://speakerdeck.com/player/1f3d480960b14e3b8f37b405a23417eb" title="::class.fixture() pattern — 拡張関数を生かした、Test Fixture 管理の紹介 " allowfullscreen="true" style="border: 0px; background: padding-box padding-box rgba(0, 0, 0, 0.1); margin: 0px; padding: 0px; border-radius: 6px; box-shadow: rgba(0, 0, 0, 0.2) 0px 5px 40px; width: 100%; height: auto; aspect-ratio: 560 / 315;" data-ratio="1.7777777777777777"></iframe>
> [::class.fixture() pattern — 拡張関数を生かした、Test Fixture 管理の紹介](https://speakerdeck.com/kazukima/class-dot-fixture-pattern-kuo-zhang-guan-shu-wosheng-kasita-test-fixture-guan-li-noshao-jie)

* [Kotlin Fest 2024](https://www.kotlinfest.dev/kotlin-fest-2024) Speaker (Based on CpF; 採択率 採択率 17 / 111 = 15%)

> <iframe class="speakerdeck-iframe" frameborder="0" src="https://speakerdeck.com/player/5de72152efc94053ac0a8e1785e3da42" title="#KotlinFest 2024 : Kotlin sealed classを用いた、ユーザーターゲティングDSL（専用言語）と実環境で秒間1,000万評価を行う処理系の事例紹介" allowfullscreen="true" style="border: 0px; background: padding-box padding-box rgba(0, 0, 0, 0.1); margin: 0px; padding: 0px; border-radius: 6px; box-shadow: rgba(0, 0, 0, 0.2) 0px 5px 40px; width: 100%; height: auto; aspect-ratio: 560 / 315;" data-ratio="1.7777777777777777"></iframe>
> [Kotlin sealed classを用いた、ユーザーターゲティングDSL（専用言語）と実環境で秒間1,000万評価を行う処理系の事例紹介](https://fortee.jp/kotlin-fest-2024/proposal/5a2b58f8-913c-4f7b-84b2-dcd359736ab9)
> > サービスの体験をパーソナライズし、興味のあるコンテンツを楽しんで貰うためには、
> > 各種クリエイティブ（バナー・ポップアップ等）のターゲティング（by 年代、性別、OS、etc）が欠かせません。
> >
> > 最初は個別に実装する事が多いですが、露出面nとターゲティング条件mが増えた場合、O(n x m) の実装・メンテナンスコストがかかってしまい、共通化が必要となります。
> >
> > 今回の発表は、新規作成された共通化Platform上における課題：『マーケターを初めとする全社員が、ユーザーの条件やその AND/OR/NOT の任意の組み合わせによるターゲティングを可能とする』を、
> > Kotlin で実装した YAML ベースのユーザーターゲティングDSL（独自言語）とその処理系によって解決した事例の紹介となります。
> >
> > 安定的な拡張を行うためにKotlinの型が果たす役割についても取り上げます。

* 標準的・基本的な Storage (MySQL, Redis, Elasticsearch) をなるべく理想的な形で運用し、安定的に 30,000 req/sec API を提供。
    * MySQL / Redis を利用した HybridCache の実装と展開 - [1日12億以上のリクエストを処理！ LINEマンガだからできる「SREエンジニア」の仕事](https://www.green-japan.com/premium_interviews/linedigitalfrontier/interview.html)
    * Elasticesarch を1級ストレージとして、MySQL Base listing からの移行を支援。
* Embedding vector を利用した、作品リストの online re-ranking 実装。
* Grafana, Prometheus を利用した Monitoring（必要に応じて自分で Gauge / DistributionSummary 実装）
* 広告・ユーザー露出制御用の Private DMP ([Data Management Platform](https://www.fujitsu.com/jp/solutions/business-technology/intelligent-data-services/digitalmarketing/column/column017.html)) の概念浸透と実装。
    * ref: [Kotlin sealed classを用いた、ユーザーターゲティングDSL（専用言語）と実環境で秒間1,000万評価を行う処理系の事例紹介](https://fortee.jp/kotlin-fest-2024/proposal/5a2b58f8-913c-4f7b-84b2-dcd359736ab9)
* ClickHouse 等のを利用した、大規模データの分析基盤構築。（補完用途）
> <iframe class="speakerdeck-iframe" frameborder="0" src="https://speakerdeck.com/player/6e6d909c7a6f4e3dba03991349b8d149" title="How LINE MANGA Uses ClickHouse for Real-Time AnalysisSolving Data Integration Challenges with ClickHouse" allowfullscreen="true" style="border: 0px; background: padding-box padding-box rgba(0, 0, 0, 0.1); margin: 0px; padding: 0px; border-radius: 6px; box-shadow: rgba(0, 0, 0, 0.2) 0px 5px 40px; width: 100%; height: auto; aspect-ratio: 560 / 315;" data-ratio="1.7777777777777777"></iframe>
> 
> en: LINE MANGA relies on numerous MySQL servers, but faced challenges with real-time analysis. Before introducing ClickHouse, we relied on custom scripts for each analysis. This approach was difficult to develop and review, and execution was slow.
>
> In theory, almost all such tasks can be done with simple SQL, which could be naturally parallelized by the query engine. However, due to our vertical and horizontal sharding, this method became impossible.
>
> ClickHouse’s integration engine resolves this issue. It allows data stored in different MySQL locations to be joined and aggregated with simple SQL. We believe this will serve as a helpful reference for improving the developer experience, as well as a good first step towards implementing ClickHouse.
>
> ja: LINE MANGAでは多数のMySQLサーバーを使用していますが、リアルタイム分析に課題がありました。ClickHouseを導入する前は、各種分析に対して個別のカスタムスクリプトに依存しており、このアプローチは開発やレビューが困難で、実行速度も遅いという問題を抱えていました。
>
> 理論上は、ほとんどのタスクをシンプルなSQLで実行し、クエリエンジンによって自然に並列化できるはずです。しかし、垂直・水平シャーディングを行っているために、この方法では対応が不可能でした。
>
> ClickHouseのインテグレーションエンジンは、この問題を解決してくれます。異なるMySQL上に分散しているデータを、シンプルなSQLで結合・集約できるようになるのです。私たちはこれが、開発者の体験を向上させる上で有用な参考例となるだけでなく、ClickHouseの導入に向けた第一歩になると考えています。

2019/10-2020/03 [LINE Corporation.](https://linecorp.com/)
------------
* Senior Software Engineer at LINE's Official Account (B2B2C Ad Platform).
    * Leads [ステップ配信](https://www.lycbiz.com/jp/manual/OfficialAccountManager/step-message/) platform.
        * Runs massive state machine on HBase/MySQL mixed architecture for each OA x user relationships, and send message depends on each state and required schedule.
* Trunk Based Development への Git Branching Model の修正などを実施


> <iframe class="speakerdeck-iframe" frameborder="0" src="https://speakerdeck.com/player/e7d02e9564994b2a8c9a27375736681a" title="Development Process Refactoring Case Study" allowfullscreen="true" style="border: 0px; background: padding-box padding-box rgba(0, 0, 0, 0.1); margin: 0px; padding: 0px; border-radius: 6px; box-shadow: rgba(0, 0, 0, 0.2) 0px 5px 40px; width: 100%; height: auto; aspect-ratio: 560 / 315;" data-ratio="1.7777777777777777"></iframe>
>
> > 本セッションでは、サーバーサイド開発チームにおいて実施した、プロセスの改善について紹介します。 2019年、チームをスケールさせるにあたって、一部の指標、例えばコードレビューが完了するまでの時間が悪化している事が問題になっていました。 そこで今回我々は開発プロセス、特にリポジトリの管理とレビュープロセスに注目して、改善を進めました。 なぜなら、素早いフィードバックと、小さな改善を高速に適用していくことが、開発のスループットを向上させることに繋がると考えたからです。 結果として、PR のマージまでの時間は 89 % 減少させることができました。 具体的なプロセス改善について、事例を交えながら知見を共有させて頂きます。
>
> [Development Process Refactoring Case Study - LINE Dev Day 2020](https://linedevday.linecorp.com/2020/ja/sessions/6992/)


2018/10-2019/09 [Cluster, Inc.](https://cluster.mu/)
------------
* General server side engineer. (Golang)
    * Design & implement IAP(In App Purchase) coin table & transaction
    * VR event archiving server side engineering lead
        * [過去のVRイベントを追体験できる「VRアーカイブ機能」　仮想空間「cluster」が提供 \- ITmedia NEWS](https://www.itmedia.co.jp/news/articles/1906/05/news108.html)
        * [VRスペース「cluster」、VRイベントを繰り返し体験できるアーカイブ機能 \- CNET Japan](https://japan.cnet.com/article/35138040/)
        * [YuNiちゃんや樋口楓ちゃん、朝ノ瑠璃ちゃんの過去ライブを体験可能に！　cluster、VR「アーカイブ機能」を正式リリース – PANORA](https://panora.tokyo/95408/)
        * [VRプラットフォームcluster、過去の配信に“入れる”アーカイブ機能をβリリース \| MoguLive \- 「バーチャルを楽しむ」ためのエンタメメディア](https://www.moguravr.com/cluster-archive/)
* VR contents studio engineering.
    * Tools: NDI (Video over Ethernet), Voice over Ethernet, Motion Capture, VIVE.


2015/02-2018/09 LINE Corporation.
------------

### 2015/02-2017/Spring

* Lead engineer of [LINE STORE //store.line.me](https://store.line.me).
    * Digital Item EC Site / Server Side Engineer.


2013/01-2015/01 JustSystems
------------
* Full stack engineer & Product Owner of [GDMS](https://www.justsystems.com/jp/products/gdms/).
    * [Working Backwards](https://www.wantedly.com/companies/toppan_dxd_ict/post_articles/501129) を全社で推進しており、新バージョンリリースの Press-Release （のイメージ）を書く部分から担当。
    * java6->java7 migration lead on Tomcat Servlet environment, JSP(HTML, CSS, JavaScript).
    * SVN -> Git migration lead.

2012/03-2012/12 Sony Global Solutions
-----------
* Supply Chain Management SE


Achievements
----
* 社内各種 Microservice / Platform との API 連携。
* REST, Thrift, Thrift Web, Google Tag Manager (GTM) and Google Analytics,

### 2017/Spring-2018/09

* B2B BizDev and Technical Consultant of O2O (Online to Offline) Division, Manager.

ref: [Techキャリア、どう広げる？ 最短距離で理想を叶える「社内転職」のススメ](https://type.jp/et/feature/8401/)

* 全社データ分析基盤上での ETL 設計 ~ Sales へのレポート設計など。  
* 特許：[【課題】実店舗で取引を行ったユーザの情報を比較的容易に取得することができる情報処理方法、情報処理装置、及びプログラム](https://jglobal.jst.go.jp/detail?JGLOBAL_ID=201903006032658084)

### Other works
* Maintainer of [LINE BOT SDK Java](https://github.com/line/line-bot-sdk-java)
* Technical Blog Entry [Spring Security + 設定ファイルで始める LINE との ID Federation](https://engineering.linecorp.com/ja/blog/detail/159)
