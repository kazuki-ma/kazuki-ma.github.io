Presentation Idea of LINE Manga's ClickHouse usage.

Abstract
====

> ストレージソリューションの導入やリプレイスには、複雑で長期にわたる作業がつきものです。本セッションでは、私たち LINE Manga のチームが、すでに確立された分析パイプラインと競合させることなく スタンドアロン／ステートレスな ClickHouse サーバー を既存エコシステムへシームレスに組み込んだ事例をご紹介します。
> 具体的には、水平方向・垂直方向にシャーディングされた多数の MySQL クラスターに対して、リアルタイムかつアドホックな分析を ClickHouse で実装しました。複数シャードを JOIN するカスタム Script 開発と比較して、SQL で完結するため柔軟なデータ探索が可能となり、いまや ClickHouse は不可欠なツールへと進化しました。
> もし部分的または段階的に ClickHouse を導入したいとお考えであれば、このセッションはよいヒントになると思います。
> これを見たあとは、きっと clickhouse-local を自分の開発でも使ってみたくなると思います。

----

Contents


Introduction
====

Happy New Year 2025! I'm [Kazuki Matsuda]. I'm a software engineer at LINE Manga. Today, I'm going to talk about how we introduce ClickHouse into our existing ecosystem without competing with our established analysis pipeline.

As a greeting to start 2025, I wish for the continued growth and success of everyone here, LINE Yahoo Corporation, and ClickHouse.

About LINE Manga
====

LINE Manga is a digital manga service operated by LINE Digitan Frontier Corporation.

We provide a wide range of manga titles, including popular series and original works. We have a large user base, and we are constantly working to improve our service.

<!-- ここで人事が Kotlin Conf の事後イベントで出したスライドを参照してサービス規模を伝える -->
<!-- data.ai の 2025 年まとめって間に合ってる？ 年額課金 Japan No1 ？ -->

We are using MySQL as our primary database.
Of course, we always consider using other databases, but we have a lot of data in MySQL, and we have a lot of experience with it.

* Sub-ms fetch time based on merge on write to Clustered Index.
  
Encountering ClickHouse
----

I first encountered ClickHouse in (maybe)2020. Maybe Okada-san's tweet or something.
Okada-san is a software engineer at LINE Corporation. And leader of Internal Messaging Hub.

Anyway, Thanks to Okada-san, I learned about ClickHouse and its capabilities.

ClickHouse is brazily fast Database. And I sometimes tried to introduce into our Production pipeline but it's a hard work and time-consuming.

Our Problem
====
And we have a lot of MySQL clusters.

And we have a lot of ad-hoc and real-time analysis.
Before ClickHouse, we implement ad-hoc and real-time analysis by custom scripts. It's hard to develop and review, also slow to execution.

Theoretically, almost all of the ad-hoc and real-time analysis can be done by SQL.
And naturally parallelized by the query engine.

But our vertical and horizontal sharding MySQL clusters make it impossible to done by SQL.


Let's start using ClickHouse.
====

I know some OSS can solve this problem like Trino etc.

But we choose ClickHouse because of
* Fast.
* Its simplicity.
* Writable if needed. (We can create tmp tables easily.)
* Provide many analytical function out of the box.


Agenda
====
0. Self-introduction
1. Problem (Why we need ClickHouse)
2. ClickHouse feature for stateless usage
3. Architecture
4. Make it to your story.
5. 


ClickHouse as a stateless server
====
ClickHouse has it's own storage engine called MergeTree for "brazily first". (I love it.)
But many other storage engines are available for integration.

[MySQL Table Engine](https://clickhouse.com/docs/en/engines/table-engines/integrations/mysql) is the one of them. And designed for MySQL integration.

It's pass through the query to MySQL and fetch the result. It's very simple and useful for us.

And all of ClickHouse features are available after fetching the result from MySQL.

* Distribution to horizontal sharded MySQL.
* Joining data on vertical sharded MySQL.


Architecture
===
In development (local) environment, we use ClickHouse as a standalone server.
And defining MySQL table engine for each MySQL shards.

Developer can write simple SQL and execute it on ClickHouse. And ClickHouse fetch the result from MySQL.

In production environment, we use ClickHouse thourhg a gateway for security and auditing.
But execution contents are the same as development environment.

This dramatically improve
* Development speed.
* Clearness of the code.
* Complexity of the system.


We love ClickHouse.







Replacing analytical platform with ClickHouse is a big project. It's a long-term project and requires a lot of effort. Especially, when you have a well-established pipeline like top of Hadoop and query engines (Spark/Trino).

But we have a different approach. We use ClickHouse as a standalone and stateless server to implement real-time and ad-hoc analysis on top of our existing MySQL clusters.

Again, even if you have already anlalytical platform, I think there is two point to ClickHouse is useful.

1. Stateless usage of ClickHouse. Using by query engines.
2. Applications where analytical substrates cannot be used, or construction of closed systems.
   (Large-scale log acquisitions for special purposes, etc.)

Today, I will talk about the first point.


ClickHosue as a stateless server
====

ClickHouse has a MergeTree based on well-known LSM-tree. Even it's a very well implemented storage engine, we don't use it.

Instead, we use ClickHouse as a stateless server. Stateless means that we don't store any data in ClickHouse. We use ClickHouse as a query engine. And state are stored in MySQL.

Because

* We have already a lot of data in MySQL.
* Managing statefull services is hard. (Including backup, recovery, auditting, etc.)




----

ClickHouse is a column-oriented database management system. It's designed for OLAP workloads, which means it's optimized for read-heavy workloads and has special storage and indexing strategies to make queries fast. We love this capabilities.

But today's my talk does not use those column-oriented features and storage formats.
Instead, we use ClickHouse as a standalone and stateless server to implement real-time and ad-hoc analysis on top of our existing MySQL clusters.

About LINE Manga.