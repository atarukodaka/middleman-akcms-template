---
title: middleman-akcms 文書管理拡張機能のご紹介
date: 2017-01-27
---

## 概要
middleman のディレクトリごとのサマリーを自動生成する文書管理システムを拡張機能として作ってみました。

[akcms - Ataru Kodaka Content Management System - atarukodaka/middleman-akcms](https://github.com/atarukodaka/middleman-akcms)

動作サンプルはこちら：[Home \- Ataru Kodaka Site](http://atarukodaka.github.io/)

スナップショット：

<div>
<a href="/images/middleman-akcms-snapshot.png"><img src="/images/middleman-akcms-snapshot.png" alt="スナップショット" style="max-width: 70%"></a>
</div>

foo/bar/baz.html を作成すると、foo/bar/index.html, foo/index.html, index.html といったディレクトリサマリーページを自動生成します。これにより、どのリソースからも parent, children でたどることができるようになります。

その他、月別アーカイブ、タグ、ペジネーション、breadcrumbなどをサポートします。
付属テンプレートでは bootstrap3をサポートします。

## インストールと使いかた
middleman4 を入れた状態で、テンプレートを指定してプロジェクトを作ります

```sh
$ middleman init proj --template git@github.com:atarukodaka/middleman-akcms.git
```

後は通常どおりにprojに入って bundle install し、source/ 以下お好きなようにファイルを作って中身を書き build や server 回します。

### 設定
#### config.rb
config.rb にて :akcms を activate し、各種設定をします。

```ruby
activate :akcms do |akcms|
  akcms.layout = "article"

  akcms.directory_summary_template = "templates/directory_summary_template.html"
  akcms.archive_month_template = "templates/archive_template.html"
  akcms.tag_template = "templates/tag_template.html"
  akcms.pagination_per_page = 10
end
```

使うレイアウトやテンプレート群を指定してください。
ペジネーションのデフォルト表示数/頁も指定できますが、
記事ごとに指定することもできます（後述）。

## 設計と機能
### 記事 / Article

以下の特徴を持ったリソースは、記事 (article) とみなされ：

- ignored でないもの
- 拡張子が .html あるいは .htm のもの
- type: フロントマターで 'article' 以外のものが明示的に指定されていないもの

以下のメソッドを持ちます：

- title：記事タイトル
- date：日付(TimeWithZoneクラス）。date: フロントマターあるいは更新日時から生成
- summary：サマリー表示
- published?：出力するか。published: false でなければ真
- prev_article：次の記事
- next_article：前の記事
- body：記事本文（レイアウト不使用）

そして、Middleman::Sitemap::Store クラス(sitemapオブジェクトが生成される）には、以下のインスタンスメソッドが追加されます。

- articles()：全ての article リソース配列（日付逆順ソート済）

これを使って、

```erb
<ul>
<% sitemap.articles.first(10).each do |article| %>
  <li><%= link_to(article.title, article) %></li>
<% end%>
</ul>
```

などと最新１０件の記事を表示することができます。

また、全てのリソースに、以下のメソッドが追加されます：

- is_article?：article かどうか
- to_article!：当該リソースを article 属性を持たせる


see https://github.com/atarukodaka/middleman-akcms/blob/master/lib/middleman-akcms/article.rb

### ディレクトリサマリー / DirectorySummary
activate の際、テンプレートを指定するとディレクトリサマリー生成機能が稼働します。

```ruby
activate :akcms do |conf|
  conf.directory_summary_template = "templates/directory_summary.html"
end
```

これにより、例えば foo/bar/baz.html というリソースがあった場合、

- foo/bar/index.html
- foo/index.html
- index.html

が（存在しなければ）テンプレートに従いプロキシリソースが生成されます。
その際、ローカル変数として、

- directory:  当該ディレクトリの情報を保持するname, path メソッドを持つオブジェクト
- articles[]：当該ディレクトリ下にある article のリソース配列

が渡されるため、

```erb
% cat templates/directory_summary.html.erb
<h1>Directory: <%= directory.name %></h1>
<ul>
<% articles.each do |article| %>
  <li><%= link_to(article.title, article) %>
<% end %>
</ul>
```

などと当該ディレクトリの記事一覧を作成できます。

#### breadcrump

全てのリソースに、ancestors メソッドが追加されるため、以下のように
breadcrumbs を手軽に作ることができます。

```erb
<ol class="breadcrumb">
  <% current_resource.ancestors.reverse.map do |res| %>
  <li><%= link_to(res.data.title || res.directory.name, res) %></li>
  <% end %>
  <li class="active">current_resource.data.title</li>
</ol>
```

#### foo/config.yml
あるディレクトリに "directory_name: "というエントリを持つ config.yml が存在する場合、
resource.directory.name はその値が入ります。


```yml
$ cat source/foo/config.yml
directory_name: フー
```

```erb
$ cat source/foo/index.html.erb
<h1>directory: <%= current_resource.directory.name %></h1> <!-- 'フー' と表示される -->
```


### タグ

options.tag_template

- resource.tags: 当該リソースのタグ配列
- sitemap.tags：タグ=>プロキシリソースのハッシュ

### アーカイブ

options.archive\_month_template

- sitemap.archives：日付(TimeWithZone)=>プロキシリソースのハッシュ

### ペジネーション

- pagination?：ヘルパ関数
- current_resource.paginator：
  - page_number
  - num_pages
  - ...

### シリーズ機能

options.series\_title_template

config.yml

```yml
series: シリーズ名
```


## Tips
### .emacs
.emacs や .emacs.d/init.el に

```elisp
(require 'autoinsert)
(add-hook 'find-file-hooks 'auto-insert)
(setq auto-insert-query nil)
(setq auto-insert-alist 
      '(("\\.html\\.md$" . frontmatter-skeleton)
	  ("\\.html\\.md\\.erb$" . frontmatter-skeleton)))

;; middleman-blog: article-front matter
(defun insert-article-frontmatter ()
  (interactive)
  (insert (concat "---\ntitle: \ndate: " (format-time-string "%Y-%m-%d") "\n\n---\n")))
(define-key global-map "\C-ca" 'insert-article-frontmatter)
```

とやっておくと便利です。

#### data/config.yml
著者名や著者・サイト情報をYAMLで記述します。テンプレートで data.config.author などと取れます。
