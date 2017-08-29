# JJSwiftNews
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	概述：基于Swift语言的资讯类应用软件
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	数据来源：阿里云提供的新闻头条，<a href="https://market.aliyun.com/products/57126001/cmapi013650.html#sku=yuncode765000000"><span style="color: rgb(0, 0, 255);">https://market.aliyun.com/products/57126001/cmapi013650.html#sku=yuncode765000000</span></a> 。
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	数据源优点：
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	1.数据类型较多，包括头条、国内、体育等；
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	2.数据格式详细，包括标题、作者、图片地址等；
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	3.数据更新快速，更新周期为5-30分钟。
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	数据源缺点：
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	1.同类型下的资讯数据种类单一，只有图文资讯，也没有区分置顶（banner）资讯和普通资讯；
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	2.没有提供增量更新接口，即无法通过上滑刷新加载更多数据。
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	<br />
	
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	已实现功能：
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	1.资讯类型展示，在页面顶部展示不同资讯类型，实现点击类型切换或滑动页面切换；
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	2.资讯列表展示，同类型下取前4条资讯置顶（Banner），其他为普通图文资讯；
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	3.资讯详情展示，点击资讯列表某一条资讯，展示详情；
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	4.置顶资讯（Banner）实现自动滚动或手动滑动；
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	5.资讯列表实现下拉刷新和上滑刷新；
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	6.实现断网情况下的重新加载。
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	<br />
	
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	未实现功能：
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	1.资讯类型手动配置，目前默认展示所有类型；
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	2.资讯列表展示不同种类的资讯，例如图文资讯，多图资讯，纯文本资讯等，目前受数据源限制；
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	3.资讯列表上滑刷新加载更多目前只能实现拉取全部的该类型资讯数据，受数据接口限制。
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	<br />
	
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	其他：
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	1.整套代码基于MVC模式，耦合性较大，在未来逐步调整；
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	2.目前代码功能较为单一，期望在未来扩展更多功能。
</div>
<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	<br />
	
</div>

<div yne-bulb-block="paragraph" style="white-space: pre-wrap; line-height: 1.5; font-size: 14px;">
	Tips:master分支已经合入重构后的代码
</div>

