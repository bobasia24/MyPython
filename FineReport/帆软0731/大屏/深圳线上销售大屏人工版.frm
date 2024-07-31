<?xml version="1.0" encoding="UTF-8"?>
<Form xmlVersion="20211223" releaseVersion="11.0.0">
<TableDataMap>
<TableData name="月度各品类销售额" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[select round(sum(ifnull(实付金额,0)),2)  总金额 ,分类 from  
profit.dw_吉客云销售明细单 
where 分类 is not null  and 分类 != '组合'
and  公司 regexp '深圳'
and 部门 not regexp '私域|线下|分销'
and  left(发货时间,7) = date_format((CURDATE() - INTERVAL 1 DAY),'%Y-%m') 
and 渠道 not regexp '样品|dg' 
group by 分类 ]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="月度各部门销售额及达成率" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[with a as (
select 
round(sum(ifnull(gmv,0)),2)  总金额  ,
case 
	when (渠道 regexp '天猫|淘宝' and 渠道 not regexp '天猫超市' ) then '天猫旗舰店' 
	when 渠道 regexp '天猫超市' then '猫超' 
	when 渠道 regexp '京东' then '京东' 
	when 渠道 regexp '拼多多' then '拼多多' 
	when 渠道 regexp '抖音|快手|视频号' then '兴趣电商' 
	when 渠道 regexp '得物' then '得物' 
	when 渠道 regexp '小红书' then '小红书' 
end
二级部门
,left(日期,7) 日期
from  
profit.ods_费用填报 
where   left(日期,7) = date_format((CURDATE() - INTERVAL 1 DAY),'%Y-%m') 
group by case 
	when (渠道 regexp '天猫|淘宝' and 渠道 not regexp '天猫超市' ) then '天猫旗舰店' 
	when 渠道 regexp '天猫超市' then '猫超' 
	when 渠道 regexp '京东' then '京东' 
	when 渠道 regexp '拼多多' then '拼多多' 
	when 渠道 regexp '抖音|快手|视频号' then '兴趣电商' 
	when 渠道 regexp '得物' then '得物' 
	when 渠道 regexp '小红书' then '小红书' 
end
order by 总金额 desc limit 15
)

select  round( a.总金额/10000,2) 总金额,a.二级部门,a.日期,
case 
	when a.二级部门 regexp '小红书|得物' then round( a.总金额/10000,2)
	else round( b.目标/10000,2) 
end  目标 from a  
left join  profit.人工导入bi线上电商目标 b
on a.日期 = b.日期 and a.二级部门 = b.渠道
where a.二级部门 is  not  null 
]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="月维度总销售额" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[with 
aa as (select round(sum(ifnull(gmv,0)),2)  gmv,round(sum(ifnull(费用,0)),2) 费用,left(日期,7) 日期1 from  
profit.ods_费用填报
where    left(日期,7)  = date_format((CURDATE() - INTERVAL 1 DAY),'%Y-%m')  
group by left(日期,7) 
)
,a as (
select 
sum(销量 * 含税单价) 成本,
渠道,
left(发货时间,7) 发货时间1
from  
profit.dw_吉客云销售明细单  
where 公司 regexp '深圳' 
and 部门 not regexp '线下|分销|私域' 
and 渠道 not regexp '样品' 
and 发货时间 like '2024%'
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分|预付卡'
group by left(发货时间,7) 
 )

select gmv 总销售额,费用 总费用,日期1,成本,(gmv-费用-成本) 利润,(gmv-费用-成本)/gmv 利润率 from aa left join a
on left(aa.日期1,7)   = 发货时间1
]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="日维度渠道冰粽毛利率" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[with a as (
select 
substring_index(substring_index(substring_index(渠道,'-sz',1) ,'店',1),'渠道',1) 渠道
,季节性产品分类
,round((sum(含税单价*销量))/10000,2) 成本
,round((sum(ifnull(实付金额,0)))/10000 ,2)  金额
,(round((sum(ifnull(实付金额,0)))/10000 ,2)) - (round((sum(含税单价*销量))/10000,2)) 毛利

from  
profit.dw_吉客云销售明细单  
where 公司 regexp '深圳' and 部门 not regexp '私域|线下|分销' 
and 发货时间 =  DATE(DATE_SUB(CURDATE(), INTERVAL 1 DAY)) 
and 渠道 not regexp '样品|dg'  
and 渠道  regexp '旗舰|抖音零食|抖音生鲜|天猫超市'
and 季节性产品分类 regexp '冰粽'
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分'
group by substring_index(substring_index(substring_index(渠道,'-sz',1) ,'店',1),'渠道',1),left(发货时间,7),季节性产品分类

)

select 渠道,毛利/金额  毛利率 ,季节性产品分类
 from  a  
 group by 渠道
 order by 渠道 ]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="报废_时间销售额以及达成率" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[with a as (
select round(sum(ifnull(实付金额,0)),2)  总金额 ,
case 
	when 渠道 regexp '拼多多' then '拼多多汇总'
	when 渠道 regexp '京东' then '京东汇总'

	when 部门 regexp '兴趣电商' then '兴趣电商汇总'
	when 部门 regexp '天猫' then '天猫汇总'
	else 部门
end
部门1,渠道,left(发货时间,7) 发货时间 from  
profit.dw_吉客云销售明细单 
where   公司 regexp '深圳'
and 部门 not regexp '私域|线下|分销'
and 发货时间 like '2024%' 
and 渠道 not regexp '样品|小红书' 
group by 部门1 ,left(发货时间,7))

select 总金额,部门1,发货时间,目标,总金额/目标 目标完成率 from a 
left join profit.人工导入bi2024年度电商销售目标 b
on a.部门1 = b.渠道  and   a.发货时间  = b.月份
order by 部门1,a.发货时间 ]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="报废五大季节品" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[with a as (
select round(sum(实付金额),2)  销量总金额,季节性产品分类,	left(发货时间,7) 发货时间 from profit.dw_吉客云销售明细单
where 公司 regexp '深圳' and 部门 not regexp '私域|线下|分销' and 发货时间 like '2024%'  
and 渠道 not regexp '样品' and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分'
group by 季节性产品分类,left(发货时间,7) order by 销量总金额 desc)

select 发货时间,
	max(case when 季节性产品分类 = '年货' then  销量总金额 else null end ) as 年货,
	max(case when 季节性产品分类 = '冰淇淋' then  销量总金额 else null end ) as 冰淇淋,
	max(case when 季节性产品分类 = '青团' then  销量总金额 else null end ) as 青团,
	max(case when 季节性产品分类 = '月饼' then  销量总金额 else null end ) as 月饼,
	max(case when 季节性产品分类 = '冰粽' then  销量总金额 else null end ) as 冰粽
from a  where 季节性产品分类 != '其他' group by 发货时间]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="日维度销售额" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[with 
aa as (select round(sum(ifnull(gmv,0)),2)  gmv,round(sum(ifnull(费用,0)),2) 费用,日期 from  
profit.ods_费用填报
where  日期 =  DATE(DATE_SUB(CURDATE(), INTERVAL 1 DAY)) )
,a as (
select 
sum(销量 * 含税单价) 成本,
渠道,
left(发货时间,10) 发货时间1
from  
profit.dw_吉客云销售明细单  
where 公司 regexp '深圳' 
and 部门 not regexp '线下|分销|私域' 
and 渠道 not regexp '样品' 
and 发货时间 like '2024%'
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分|预付卡'
group by left(发货时间,10) 
 )

select gmv 总销售额,费用 总费用,日期,成本,(gmv-费用-成本) 利润,(gmv-费用-成本)/gmv 利润率 from aa left join a
on aa.日期   =  a.发货时间1 
]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="日维度贡献榜" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[
select 日期,substring_index(渠道,'店',1) 渠道,round(sum(gmv)/10000,2)  金额,sum(费用) 费用 
from profit.ods_费用填报
where 日期 =  DATE(DATE_SUB(CURDATE(), INTERVAL 1 DAY)) 
group by 日期,渠道 
order by  round(sum(gmv)/10000,2) desc limit 8]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="年累计销售额" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[select round(sum(ifnull(实付金额,0)),2)  总金额 from  
profit.dw_吉客云销售明细单  
where 公司 regexp '深圳' and 部门 not regexp '私域|线下|分销' and 发货时间 like '2024%'  and 渠道 not regexp '样品|dg' 
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分']]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="同比分析" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[

with a as (
select round((sum(ifnull(实付金额,0)))/10000,2) as '2024年',concat(month(发货时间),'月') 月份 from  
profit.dw_吉客云销售明细单  
where 公司 regexp '深圳' and 部门 
not regexp '私域|线下|分销' 
and 渠道 not regexp '样品|dg' 
and 发货时间 like '2024%'
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分'
group by left(发货时间,7) 
)

select a.月份,a.2024年,b.2023年 from a join 
(select concat(month(concat(时间,'-01')),'月') 月份
,round(复核订单金额/10000)  '2023年' from 
profit.人工导入bi2023线上销售统计) b
on a.月份  = b.月份;]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="日维度渠道冰淇淋毛利率" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[with a as (
select 
substring_index(substring_index(substring_index(渠道,'-sz',1) ,'店',1),'渠道',1) 渠道
,季节性产品分类
,round((sum(含税单价*销量))/10000,2) 成本
,round((sum(ifnull(实付金额,0)))/10000 ,2)  金额
,(round((sum(ifnull(实付金额,0)))/10000 ,2)) - (round((sum(含税单价*销量))/10000,2)) 毛利

from  
profit.dw_吉客云销售明细单  
where 公司 regexp '深圳' and 部门 not regexp '私域|线下|分销' 
and 发货时间 =  DATE(DATE_SUB(CURDATE(), INTERVAL 1 DAY)) 
and 渠道 not regexp '样品|dg' 
and 渠道  regexp '旗舰|抖音零食|抖音生鲜|天猫超市'
and 季节性产品分类 regexp '冰淇淋'
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分'
group by substring_index(substring_index(substring_index(渠道,'-sz',1) ,'店',1),'渠道',1),left(发货时间,7),季节性产品分类

)

select 渠道,毛利/金额  毛利率 ,季节性产品分类
 from  a  
 group by 渠道
 order by 渠道]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="利润" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[with 
aa as (select sum(gmv) gmv,sum(费用) 费用,left(日期,10)日期 ,渠道 from profit.ods_费用填报
where 日期 = DATE(DATE_SUB(CURDATE(), INTERVAL 1 DAY)) 
group by left(日期,10),渠道)
,a as (
select 
sum(数量 * 含税单价) 成本,
case 
	when 渠道 regexp '拼多多企业' then '拼多多糕点官方店' else 渠道 
end

渠道,
left(下单时间,10) 下单时间1
from  
profit.dw_吉客云销售明细单_下单 d吉下  
where
 部门 not regexp '线下|分销|私域' 
and 渠道 not regexp '样品|gd' 
and 下单时间 like '2024%'
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分|预付卡'
group by left(下单时间,10) ,渠道
 )

select gmv,费用,日期,substring_index(substring_index( aa.渠道,'店',1),'渠道',1)  渠道,ifnull(成本,0) ,(gmv-费用-ifnull(成本,0) ) 利润,(gmv-费用-ifnull(成本,0) )/gmv 利润率 from 
aa
left join a
on aa.日期   =  a.下单时间1 
and aa.渠道 =  substring_index(a.渠道,'-sz',1)
order by gmv  desc limit 10]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
</TableDataMap>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<FormECParallelCalAttr useServerSetting="false" parallelCal="true"/>
<FormMobileAttr>
<FormMobileAttr refresh="false" isUseHTML="false" isMobileOnly="false" isAdaptivePropertyAutoMatch="false" appearRefresh="false" promptWhenLeaveWithoutSubmit="false" allowDoubleClickOrZoom="true"/>
</FormMobileAttr>
<Parameters>
<Parameter>
<Attributes name="name"/>
<O>
<![CDATA[广东]]></O>
</Parameter>
</Parameters>
<Layout class="com.fr.form.ui.container.WBorderLayout">
<WidgetName name="form"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<ShowBookmarks showBookmarks="false"/>
<Center class="com.fr.form.ui.container.WFitLayout">
<WidgetName name="body"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WAbsoluteBodyLayout">
<WidgetName name="body"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="Arial" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ColorBackground">
<color>
<FineColor color="-15985098" hor="-1" ver="-1"/>
</color>
</Background>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="chart1"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="chart1" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ChartEditor">
<WidgetName name="chart1"/>
<WidgetID widgetID="75cddfe2-b567-438a-9692-6accc1a94fba"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="15" bottom="15" right="15"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0"/>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="黑体" style="1" size="128">
<foreground>
<FineColor color="-11316397" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Position pos="2"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LayoutAttr selectedIndex="0"/>
<ChangeAttr enable="false" changeType="button" timeInterval="5" showArrow="true">
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="PingFangSC-Regular" style="0" size="96">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<buttonColor>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</buttonColor>
<carouselColor>
<FineColor color="-8421505" hor="-1" ver="-1"/>
</carouselColor>
</ChangeAttr>
<Chart name="默认" chartClass="com.fr.plugin.chart.vanchart.VanChart">
<Chart class="com.fr.plugin.chart.vanchart.VanChart">
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="true">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-1118482" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<ChartAttr isJSDraw="true" isStyleGlobal="false"/>
<Title4VanChart>
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-6908266" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[新建图表标题]]></O>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Microsoft YaHei" style="0" size="128">
<foreground>
<FineColor color="-13421773" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="false" position="0"/>
</Title>
<Attr4VanChart useHtml="false" floating="false" x="0.0" y="0.0" limitSize="false" maxHeight="15.0"/>
</Title4VanChart>
<SwitchTitle>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[默认]]></O>
</SwitchTitle>
<Plot class="com.fr.plugin.chart.column.VanChartColumnPlot">
<VanChartPlotVersion version="20170715"/>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor/>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isNullValueBreak="true" autoRefreshPerSecond="6" seriesDragEnable="false" plotStyle="0" combinedSize="50.0"/>
<newHotTooltipStyle>
<AttrContents>
<Attr showLine="false" position="1" isWhiteBackground="true" isShowMutiSeries="false" seriesLabel="${VALUE}"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
<PercentFormat>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.##%]]></Format>
</PercentFormat>
</AttrContents>
</newHotTooltipStyle>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name="">
<AttrList>
<Attr class="com.fr.chart.base.AttrBorder">
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="3"/>
<newColor autoColor="true" themed="false">
<borderColor>
<FineColor color="-1" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
</Attr>
<Attr class="com.fr.chart.base.AttrAlpha">
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</Attr>
<Attr class="com.fr.plugin.chart.base.AttrTooltip">
<AttrTooltip>
<Attr enable="false" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: left;&quot;&gt;&lt;img data-id=&quot;${CATEGORY}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${SERIES}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${CATEGORY}${SERIES}${VALUE}"/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="true" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.5"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</Attr>
<Attr class="com.fr.plugin.chart.base.AttrLabel">
<AttrLabel>
<labelAttr enable="true"/>
<labelDetail class="com.fr.plugin.chart.base.AttrLabelDetail">
<AttrBorderWithShape>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="true" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
<shapeAttr isAutoColor="true" shapeType="RectangularMarker"/>
</AttrBorderWithShape>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
<Attr showLine="false" isHorizontal="true" autoAdjust="false" position="9" align="9" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="宋体" style="0" size="72">
<foreground>
<FineColor color="33023" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="宋体" style="0" size="72">
<foreground>
<FineColor color="33023" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: center;&quot;&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${VALUE}"/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="false" isCustom="false" isRichText="false" richTextAlign="center" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#,##0.00]]></Format>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="function(){ return this.value + &apos;万&apos;}" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
</labelDetail>
</AttrLabel>
</Attr>
</AttrList>
</ConditionAttr>
</DefaultAttr>
</ConditionCollection>
<Legend4VanChart>
<Legend>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-3355444" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr position="1" visible="true" themed="true"/>
<FRFont name="Microsoft YaHei" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Legend>
<Attr4VanChart floating="false" x="0.0" y="0.0" layout="aligned" customSize="false" maxHeight="30.0" isHighlight="true"/>
</Legend4VanChart>
<DataSheet>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="true">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isVisible="false" themed="true"/>
<FRFont name="Microsoft YaHei" style="0" size="72"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
</DataSheet>
<DataProcessor class="com.fr.base.chart.chartdata.model.NormalDataModel"/>
<newPlotFillStyle>
<AttrFillStyle>
<AFStyle colorStyle="1"/>
<FillStyleName fillStyleName=""/>
<isCustomFillStyle isCustomFillStyle="true"/>
<PredefinedStyle themed="true"/>
<ColorList>
<OColor>
<colvalue>
<FineColor color="-10243346" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-8988015" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-472193" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-486008" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-8595761" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-7236949" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-8873759" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-1071514" hor="-1" ver="-1"/>
</colvalue>
</OColor>
</ColorList>
</AttrFillStyle>
</newPlotFillStyle>
<VanChartPlotAttr isAxisRotation="false" categoryNum="1"/>
<GradientStyle>
<Attr gradientType="gradual">
<startColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</startColor>
<endColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</endColor>
</Attr>
</GradientStyle>
<VanChartRectanglePlotAttr vanChartPlotType="normal" isDefaultIntervalBackground="true"/>
<XAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="true"/>
<AxisLineStyle AxisStyle="1" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="3"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-2500135" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="2" secTickLine="0" axisName="X轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
</VanChartAxis>
</XAxisList>
<YAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartValueAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="false"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="2"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=10"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
</VanChartAxis>
</YAxisList>
<stackAndAxisCondition>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name=""/>
</DefaultAttr>
</ConditionCollection>
</stackAndAxisCondition>
<VanChartColumnPlotAttr seriesOverlapPercent="20.0" categoryIntervalPercent="20.0" fixedWidth="true" columnWidth="5" filledWithImage="false" isBar="false"/>
</Plot>
<ChartDefinition>
<MoreNameCDDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<TableData class="com.fr.data.impl.NameTableData">
<Name>
<![CDATA[同比分析]]></Name>
</TableData>
<CategoryName value="月份"/>
<ChartSummaryColumn name="2023年" function="com.fr.data.util.function.SumFunction" customName="2023年"/>
<ChartSummaryColumn name="2024年" function="com.fr.data.util.function.SumFunction" customName="2024年"/>
</MoreNameCDDefinition>
</ChartDefinition>
</Chart>
<UUID uuid="0512a300-8975-480b-a221-f1f28a669c81"/>
<tools hidden="true" sort="true" export="true" fullScreen="true"/>
<VanChartZoom>
<zoomAttr zoomVisible="false" zoomGesture="true" zoomResize="true" zoomType="xy" controlType="zoom" categoryNum="8" scaling="0.3"/>
<from>
<![CDATA[]]></from>
<to>
<![CDATA[]]></to>
</VanChartZoom>
<refreshMoreLabel>
<attr moreLabel="false" autoTooltip="true"/>
<AttrTooltip>
<Attr enable="true" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="" isAuto="true" initParamsContent=""/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="true"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="4"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-15395563" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</refreshMoreLabel>
<ThemeAttr>
<Attr darkTheme="false"/>
</ThemeAttr>
</Chart>
<ChartMobileAttrProvider zoomOut="0" zoomIn="2" allowFullScreen="true" functionalWhenUnactivated="false"/>
<MobileChartCollapsedStyle class="com.fr.form.ui.mobile.MobileChartCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
</MobileChartCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="359" height="150"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="10" y="388" width="359" height="150"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<Listener event="afterinit">
<JavaScript class="com.fr.js.JavaScriptImpl">
<Parameters/>
<Content>
<![CDATA[setTimeout(function(){
	$("div[widgetname=REPORT3_C_C_C]A").find(".reportContent")[0]A.style.overflow="hidden"
},100);]]></Content>
</JavaScript>
</Listener>
<WidgetName name="report3_c_c_c_c_c_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report3_c_c_c" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report3_c_c_c_c_c_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="1" left="1" bottom="1" right="1"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__9BB2985780BA65AD1EEF95B35E198624">
<IM>
<![CDATA[>uh82;Y_49[sY/7bUZq=@@3Qs8oi-LV(>=md7MS^PXTAnS8cRr9UuE+)&5l/=h[R7^`!?pnq
i0:b?2pNUn`L.>DnjPi_,Lk$6/0AbY.,HkFR&#kI]AX?q^n/Pl&_RoAh0ubJj:G7[(gN-#R$G
FhIDP)(9^60*;i)F'-FTbG?@>&E\t*Wr/aokM@/1Q)>VXV5?7?@CRY:_9kYZtV62@DA@-oVn
GRWr1O07LG>t_:cTeT\?R"$)(`KQe",<tI5s,8.2g0Vm&nlQ/"ObNNZk"td@nJ<6_`[C:7<7
kLIj[#qE>?Am=Y*U_]AF0GA=<L2r.4c.@%[i1_1VqBMllF16kJAAK*eWdfE?033,X9D.Bq*<Z
r,bYAlfurr/EL:nN.jI6+6D"nc(k\U5[UTLSlh4'ES]ABhN8BqUDL55aftgDA=bp_hH>DLcO]A
"jFfduJC&Zh_tcsY.ENh9raC&#DkA*LMY=j>7_orPP/22?HXT"K>HG`qZ`S3i+tCQmM8">,2
"2:E]AMm]Aa3]AR+qq5Y`1VMcKuC^dFtBm2qVdi%jS35Qak1pdYjW_]AeQ;a3GTk:Uh5QadLrGVT
uC@Z1)c`;^U>l@@P+@(J\/^$W9[#bE-q;u=YR!29V_;q_mOsI-q;`RjKTKM*l^!8'Vd]A;fbS
Y1<l7a9Or@2'UhWVK+&nh*qR<=%'kYXb4@cY`G`d$$@[+XA%Y)N:P=-(:q7HNfL_r<MF))&`
A>f;8"XS2Yp>WSQa`0%oR)Y3P]A1+n2h*ptpkA"2)0m/jQ*d2a5h6#C^d.m;2i_K]Ae@+KH_[9
l?]AM"NP"J&t`;6`:MRd>Y&+DR?,S-;fh$O51V2<,SCjDW>(f:^9XI]AJP#k3lZi-gASN44,n6
5EATFt>dL;Q.[]ABs]AC7prlR8`3+^UXTr;J=J6*XI:)SL+1I>h.&(p&16o0%=6-["RV/l9Pfe
@p7GDQFV$nTCK=b%iA$UF,["VC$RP"R91F.2DMI0O]AYHnq6)3![M(0C%:Z+d15^Tj,Ze?MdE
;2?YZV#c)&nQS&091p(!]AagAY`/HFd!4e>I2b[`&d7Ce@@51.RFDiRJNZ_PY>Elc%pnIR3mJ
ohj\6Zpa`:]Ao,+TpIKMubQs8n'DF;'2nUZ#-VLem0r-i6[SskC3]A(6pgYa=s8?KKdk>riI81
&]A8;<Z*bpYB81Z2HP\l!UQQjcXC8VIsX8'qBL%ZD;$4=-#qjI38I0\b6OH_YtNRdDm`CQ+ca
kbXn6&,&BH]A#d1r,@ndk(Opf9:<Uk<'U/0U+]AHMt5L1f8Up*#eTj3?^45_g^phN2'.hU:`dW
BkX6?@gNfa6$DKP7(\\:T(Z05Y0,BFOT?^*aSrUs4fn^N7Zc("DhnIqLY3h8_/Ta6,XanNq^
A-O4XL^kE!PJAHdN/Q2h,DO.JKLmW?DsV%j".?1`8:pR308LReIJH@M-\MJ0I%N6L&-8K:KF
dpGj[.i`3K4E>=n2%V%Ua`m65I`Fgr*s%$IHRCg_O/R1UU7?["d,9TZlOJIC:tYl:1IUW)CD
9Kf0B9.p+E4&V;U_V0N:)uE!1.@[dZ->M4q]A?rFnBmFF-<3L<ZgN0d]ASc!QtNa2/CEk@6A&4
%c$)HH]AYPXa,1oi2<GNW.C[L<T1eRl#'=dp(ADRp9kLqH%bO;SIBb!*[SXMRTSCYfA>nUL)^
Kt!bel+YJS=5;1=T\:Z9ZK0U[8sU;T<TrJ@%[JST)4>(filO!UZJ1-E1AibDi1:i3a5%q`@Z
Sj9a7>;,(85(EgQ8gH@(=ipZ4tC5QDU9klY,)kP]ArNpd?Mm^XeqI@.SQHi=\_pLM5FXK25:G
U450B_q08=bWb@sEQ]A+Y'Q+--Cqf-l?B;grndZHqQ0+[eg,6(2I=dUB3#9!0K"9l[J=%-oCa
aomADT5;B0/LC1[1&LfrI(4JltH3Gs#%A!Kb"<$hEQq/sQU%QU3?%RF:#F29Q&0N)JKFoL0^
4-`mBKXbcg3\B-^QYio`8.7Pu@I8pCT#/GHo2jlX!K0(qI3rkd.>i[7P.I+:iSOhRB&Q&C#G
@1XI2r"C82?P*#eiOnM3lB1l3J)B"_S"&&0..BN,m$;6*HBh"-i!qG@uD4#Zs!sc#!EKdZAD
6/`1JJ\[&@B*.A.4<@0<"/1m.hE]AmX_Is*e`-L5Q&BG7cu,R)>JbX:o_\D=#>GT#Os#?4&73
+LCDj$UELchmL7<0&Non0$5<#"6_fL?]Ah!7lE6rd!^_rTPWOI$mr_r[SnBNGY2$PUc0+LP)Q
Ta&jgnTHS5'Meg'#W26\sP!W9gXY`>Y;TS*.DGRDlaAVe4/$Qda[0/d*.U^o8*jejF:`oo8a
qfWmsY56RDPi&J8lY,ZT,Le/g:U=7$e;Fbl4JugS+N&!'XNf-W^:%9gR4^!>_db8H=ESU'Vh
!b.n&F+&Xno1S3qFm4EKnGg3T4_He+cHoq[IF+%4T$>\T\)\^`"i/B5ZWDJbq9K"I=`<@#Q6
NoOP;3raeA"c=oP"TF#hh#f$CHY-e[t*1VS5T9e'tqNF&.c43en5,g%?:Rt%.G_t55t8^&S=
.Di3!%4s"sb#O8nEbc:p&Kp=dG'o+g$R(EUjI7DSF_D)Z*,SP_a14bM)&3sh-bK&=CFIeYoM
/65a5#SI1tss)Eu:!&b5U#[2sg.CGHO4+PT4g0a$/E)=DV;1WLVFMfg?g4s"r&tY\3R2f_>#
js"MJj.TQ?B:mQ%9,'+8%I3q/YFXgfleQuVomg%`-#MEZ(B%W!O[^'#.pZoN-5p2Q2R#,W5!
eHHJ:h="J=;9fpBViQ)^M4>60?BKhF+<%R~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[1143000,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[457200,3139440,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0">
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="1" r="0" s="0">
<O>
<![CDATA[利润分析]]></O>
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style imageLayout="1">
<FRFont name="SimSun" style="0" size="120">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[m?E**dWZbQ^ZFV3VX^Un/+X!-*KO?@E!GIo#ACH+\D23)QmlHdB[$uc`de2+lQ2^)(RKoGj+
it,>J"<c2MWPK(L>5u@HX2k9p>p:)'LDPr()K>>]A"uJTD/-[p\B3nTBGP3rk*`g^/^&KIqJ"
&!!'qRmjT^kJ1"b*&@6jlm./9/(h#0"Ur4#b(%,Rf*_[0KoU[JD3M.uT6Z#,H'=.C:&IQ#%q
lD\u;_l'U\*_6MY*^6kqprHq:[+j(]Ar:FiGAljD+gn-d71js4*rC[B[;\;=;1po-E!H:q'ua
WTVYdu=*Hg3)44jENU=B)qZqf^Hj<Q;=3T^`VV'4#H75s*2DW03L=n_"G2c\]A9l\,]Agk+#.M
h?#gP+Rc-g)jXR'?A%2_S#kqAQT$R8KGdr4SliQ'QC&p'?*ptS<#Y59T[!PrTL1Vc&=Oe?41
t""B%LtFm(i4$[QGTdSJ,%8%/<$D!*aa5eU=&Q%tj;kUK+,C#'oL96T[u_csJq[/;6ecr\4e
Ca)`ukBc:YIA1EAKj<87n\2XaWc>?aH=G.oJS=]A3sF=>b:TZn?+rSohdgU?*Zd\$QmdRHB-7
3LlqPtZqS1N+.J)WGEm(OE3K>Rnb+:WX&[qt-M<r]AuOo6BgRB)6Y`!p)pir?'R7r0>3B4ptY
tO"km+"g6'D:+,E5@f.QC??dZV-oP$CQaqe`;*%:X[,]Ats_K.iK7r!7.An*/NTm(`;eKFf1@
5q6#l-9B)L/bZDV2+%2,Tq)DKp1C0X6l(SNPa!VNOWT?L#h-I7c0hP3WLp(.&1,/sRA&;-2d
m(`,t0!e+5G[X]A^hunj5[<R-`f1T=`on+SLr7%PV$t;_]A2_-a:7:q9TKY5H,/32$[k>cI$K3
'7N:$L/*Aku_E-7f1`@GWo8Hnr3eP#AGhC0e_eYb9(]A>b.675T9CNsaRhWX$"q@MfYm#3M:S
UJ1ec,+q'<W9^c?\?BQ).S*k)kgJ^3ati=I9s1p0Ysk+GpoE*+'8sQVkpdZbL?&lZr$2*gd+
dr=$S4lH)IX4J%0%d[mMBefr=jP:=6]A3Ar0YJQB$F=C0n)EYp*(/_$^_!2%Eq<Bj*+5Um^Bs
fO'n\N7Jm6qm&\>LT!UI>7gX4+8g%E9]AqT!Q%Qi%aX6U'Fus^GhT9]ArS+DF_W[]A`mUD7VR?C
M7.T(F'Z-QaE!"r/kAn]A6\C!iA6-*.Y#"A+$%^HB\g-LB<dlo,VQ1N>es_=Ci1R`I>qiE,TB
r[c,(n/)6D','<SKAq]AdB*=*q=-XAO3jq6M@iJ&^AQBnjF$E,Q>Euf.MEUhX0a[E[LnDN.na
u+dt]AHpF]AGNA<;789q8;XG5sH_>etZJbNIm68#pPCkmEk*<:mP+'M:C;7QK'm&9k'1E[.ieu
#V+'2W[#%$3;ig'F:AkJfUL1cS%/L=X>7;UfhF6L@#XbT64l-@Ycl0ZK.FbN[T82hATlcH]A_
O#I$f=6Ak2d5Xo;j=Q=Q`-[mo-kU_&.J,?1T8A1@So$#_B[@abaPaOEhDm;>+7tuJ+]A<1Vj%
Q1nD!j:U&9Vk5S[mhW[b#9]ATO<g[5dT>]A$TBo(O*_[50)GerRDYU`eNW3BZ(E#S>a#N>%j]At
%Pf')0aSX)IK8HhdgOgc(_`m3nQShMpPV&CBH,p7.'plMc]AILlHhe=1UI4oYNdMF)>H;p+G+
VUnLJ3dnYZEAY>rcE8;jLD)JHr_K0RH`"p1]AH59QT&\BD`2%:%nZ-^\efdSZO8BD).PmfP@U
t6)#'#Ii'Zm,R="8HTfD-YNA&_J#*86*FH`t9gBUeOpkB#>S`qecPEf=m1s7h>*_b(2`hfd*
cF5%K3@:!tq>t#j*^"A_'q-#IbfA+np=RZrj:Y8?ZPmYM!FoJWc&>R7r7u?(L$h2!V<uq5]AN
Rh(l=ftJN,>pS>gM&loeZ<\kV*0f5F\=JD3!ASY3*H3R!LT'2/k]A:FQU-t9\Wm^+PMGEZ"n?
sr-16LdP!nScrHV#e+G/N)ENI#en^Zc8'K,"R0.VDAE=f@H`\ST)@Q&^63YM5IJNi]ABS&tcU
>Z.P[&WZu/6[_B[V./mHWi]AL6pVMT5nl^Q'LY5$6pVMT5nl^Q'LY5$6pVMTs*+*QPO$t17OA
$NOg0tCeuo5ePXh]AsMPFA*YgjQD=(0G]A)ZO`8:[[NH]A_k=:0(R/fG^!lLeQp]AIrtb~
]]></IM>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="0" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="267" height="23"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="686" y="357" width="267" height="23"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="report00_c"/>
<WidgetID widgetID="4af8d295-dac4-4fa3-ac4c-7dc9d29ea052"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report0" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<ExtendSharableAttrMark class="com.fr.base.iofile.attr.ExtendSharableAttrMark">
<ExtendSharableAttrMark shareId="1cf0d1f5-bc9b-4e6d-a6ca-8ed670d1e4a3"/>
</ExtendSharableAttrMark>
<SharableAttrMark class="com.fr.base.iofile.attr.SharableAttrMark">
<SharableAttrMark isShared="true"/>
</SharableAttrMark>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report00_c"/>
<WidgetID widgetID="85ebca3d-5d4e-400a-9614-8f91ddecab78"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="【使用该组件前，请先安装模板组件复用插件 https://market.fanruan.com/plugin/0a49e40f-99da-48c7-950e-54a24e853204】
决策报表body样式的背景颜色设置为#000000">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[243840,685800,762000,762000,243840,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[609600,952500,2971800,5029200,1333500,1866900,1828800,3314700,5524500,1828800,3535680,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0" cs="11" s="0">
<O t="XMLable" class="com.fr.general.ImageWithSuffix">
<FineImage fm="png" imageId="__ImageCache__89F3BBE1F51BDFD6B03D2AEEF04A7484">
<IM>
<![CDATA[lO<9(kN.ld@UNU%p%320@UNRm!OCB<fRW%WPpc0S<2-:K@n=S/\$mB'%iFf?3,[k`&tmY&TP
_30iKAP8hbqQicT*;'lX-9r,77Dp0]AgoW*$-UA/,bh%Mk6IhSs+[QA;6j@LfRXrW>?&-4=^H
<LgelZ>VlA'>-@jsT&.`q$$a&X\ZBjEBEA/~
]]></IM>
</FineImage>
</O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="0" r="1" s="1">
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="2" r="1" s="1">
<O>
<![CDATA[昨日销售额]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="3" r="1" s="2">
<O t="DSColumn">
<Attributes dsName="日维度销售额" columnName="总销售额"/>
<Condition class="com.fr.data.condition.ListCondition"/>
<Complex/>
<RG class="com.fr.report.cell.cellattr.core.group.FunctionGrouper">
<Attr divideMode="1"/>
</RG>
<Result>
<![CDATA[$$$]]></Result>
<Parameters/>
<cellSortAttr>
<sortExpressions/>
</cellSortAttr>
</O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="7" r="1" s="1">
<O>
<![CDATA[本月销售额]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="8" r="1" s="3">
<O t="DSColumn">
<Attributes dsName="月维度总销售额" columnName="总销售额"/>
<Condition class="com.fr.data.condition.ListCondition"/>
<Complex/>
<RG class="com.fr.report.cell.cellattr.core.group.FunctionGrouper"/>
<Result>
<![CDATA[$$$]]></Result>
<Parameters/>
<cellSortAttr>
<sortExpressions/>
</cellSortAttr>
</O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="9" r="1" s="1">
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="10" r="1" s="4">
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="0" r="2" s="1">
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="2" r="2" s="1">
<O>
<![CDATA[昨日费用]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="3" r="2" s="2">
<O t="DSColumn">
<Attributes dsName="日维度销售额" columnName="总费用"/>
<Condition class="com.fr.data.condition.ListCondition"/>
<Complex/>
<RG class="com.fr.report.cell.cellattr.core.group.FunctionGrouper">
<Attr divideMode="1"/>
</RG>
<Result>
<![CDATA[$$$]]></Result>
<Parameters/>
<cellSortAttr>
<sortExpressions/>
</cellSortAttr>
</O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="7" r="2" s="1">
<O>
<![CDATA[本月费用]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="8" r="2" s="5">
<O t="DSColumn">
<Attributes dsName="月维度总销售额" columnName="总费用"/>
<Condition class="com.fr.data.condition.ListCondition"/>
<Complex/>
<RG class="com.fr.report.cell.cellattr.core.group.FunctionGrouper"/>
<Result>
<![CDATA[$$$]]></Result>
<Parameters/>
<cellSortAttr>
<sortExpressions/>
</cellSortAttr>
</O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="9" r="2" s="1">
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="10" r="2" s="6">
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="0" r="3" s="1">
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="2" r="3" s="1">
<O>
<![CDATA[昨日利润]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="3" r="3" s="2">
<O t="DSColumn">
<Attributes dsName="日维度销售额" columnName="利润"/>
<Condition class="com.fr.data.condition.ListCondition"/>
<Complex/>
<RG class="com.fr.report.cell.cellattr.core.group.FunctionGrouper">
<Attr divideMode="1"/>
</RG>
<Result>
<![CDATA[$$$]]></Result>
<Parameters/>
<cellSortAttr>
<sortExpressions/>
</cellSortAttr>
</O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="7" r="3" s="1">
<O>
<![CDATA[本月利润]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="8" r="3" s="5">
<O t="DSColumn">
<Attributes dsName="月维度总销售额" columnName="利润"/>
<Condition class="com.fr.data.condition.ListCondition"/>
<Complex/>
<RG class="com.fr.report.cell.cellattr.core.group.FunctionGrouper"/>
<Result>
<![CDATA[$$$]]></Result>
<Parameters/>
<cellSortAttr>
<sortExpressions/>
</cellSortAttr>
</O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="9" r="3" s="1">
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="10" r="3" s="6">
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="0" r="4" cs="11" s="0">
<O t="Image">
<IM>
<![CDATA[lO<9(kN.ld@UNU%p%320@UNRm!OCB<fRW%WPpc0S<2-:K@n=S/\$mB'%iFf?3,[k`&tmY&TP
_30iKAP8hbqQicT*;'lX-9r,77Dp0]AgoW*$-UA/,bh%Mk6IhSs+[QA;6j@LfRXrW>?&-4=^H
<LgelZ>VlA'>-@jsT&.`q$$a&X\ZBjEBEA/~
]]></IM>
</O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style imageLayout="4">
<FRFont name="SimSun" style="0" size="72"/>
<Background name="NullBackground"/>
<Border/>
</Style>
<Style horizontal_alignment="0" imageLayout="1">
<FRFont name="宋体" style="0" size="80">
<foreground>
<FineColor color="-2958103" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
<Style horizontal_alignment="0" imageLayout="1">
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#,##0.00]]></Format>
<FRFont name="微软雅黑" style="1" size="96">
<foreground>
<FineColor color="-14439937" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
<Style horizontal_alignment="0" imageLayout="1">
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#,##0.00]]></Format>
<FRFont name="微软雅黑" style="1" size="96">
<foreground>
<FineColor color="-8988015" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
<Style horizontal_alignment="0" imageLayout="1">
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#,##0]]></Format>
<FRFont name="微软雅黑" style="1" size="96">
<foreground>
<FineColor color="-8595761" hor="4" ver="0"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
<Style horizontal_alignment="0" imageLayout="1">
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#,##0.00]]></Format>
<FRFont name="微软雅黑" style="1" size="96">
<foreground>
<FineColor color="-8988015" hor="1" ver="0"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
<Style horizontal_alignment="0" imageLayout="1">
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#,##0.00]]></Format>
<FRFont name="微软雅黑" style="1" size="96">
<foreground>
<FineColor color="-8595761" hor="4" ver="0"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[m@&6$;d&k`RIR[.aC##V77EH$9(.W@70EbX&<nBe6Bd)JVunFR-q0@9OV3chW<!Wf;Tqr^+9
VrV6@_T50uP>&89.LJB&<8Gc[G4g^[dH`PE>aE[Eh$PT=)D*[Eg(59/BH(6c)/V6D@O6?a(+
Tg+"a$[)Hq'2W0q//U>c26De+n>W?pP,(H#jo83*1V"W&W]A:Kur:s"0]Aqa$]AsrnVLZ%sfj4V
r^#o3MQ4la0tSd/oSFn?u>:JT_n64T4\n!/6>rDqX)mANkbJillZ1k[ra+VVi8;RnsbD0qiN
b-Ym)qhYegCO0lYh/bFjT\eM[%e)\F->pFKfOV3`%S+o7+Y$7ZoJpPY,0W:PPNSC$$P<Anf1
2im?fs5iCZGoAC+m_XMqnkb9SU;bpkU#-;<0sX,4cP9-W#WZ3pO#IX`3d"_=C>846cS=/T_n
EOJ++`X&Kq:BojlV@$NlLBi?/cCkqR7)D;JD+i-7f-Ubh><g,>:B092h0JH@Q+f5;FcnTENi
#<?oIARS,'(dSNnTO;pt%Qt]A',6ACldC(*+]AF*]A5sRMb,/gV^\W=`/DV:U/<c5oJ6EnIP/fa
.h9>;<eZ$P%bZ4&E8=#m[_UQP\>)s7s)0JV2CQ*1,H'VVl%o+T[:;T_*T0!>`Y5aYdsD+WFu
n[AU382*n`#%ZDWW.JZohC=5/6Jqe&k:EAHOsaMVJn$@bD?\\Ml2Q=EI<6ZUd-+cC@u_)7><
o6o&98-eMW=<ui/*FiPd<%V*=['s,'MS:si3fAtTI_Of2MFX\_>c;F!l;=Ve)(Nrq5!3HJ+A
S_`PE:CW9[]AZYmf6#[df?n)-e]AXXGmPQrHrE,*2R_HN^9h<70tK2M)7@#Q_-WM?EBT'B94]AN
(6c7=8J]A\8Z)"32biNHOfPL;38\u,WV[<.<E]ATZs16Sr]AC<Oi-!"MLg!rc4pm*:JtNg3=ZIU
d7mr7&DspX9Wr!qJuLr>oFO2'-![A$@@)Ieh/p>RON5'mHE[i>Z>KD@N^/9"-k<.@q^bBLXc
nS04F4#8\%H1`pTAYj<U6%B<F?[?al2#G.,C%Rah=MNo`Q\J-Ni[An]A_4b$EVq%X;&=[b"Hq
DiUI?ZTH%a6Vn,TM)+-7LZgF.`H`s%[DP6N"uj(OE?\F@b>:A6[Q,gE5`N,'>S$\oQC-[5CV
rtM,#13A)4KA$pfrc)l%q$]A*A(Wi3lZg,2hI9!p_a[dgS1llH"Ha]A=-4<i5lpLoj7l5L(.W9
Nn'4RT&%]AKO<HBVe.UKXjo<`Mi.#$sKB-`N`E!i%Kep-g82k;91#o7%"]AgZjG.gB/LOgW#;(
gc6Z^NB6lCoO8@J5B.Z>%\hZ;J6PAi`nmD#1d%k"dXZ7'3HfWNj1V2>Y2:-!dEAl/,i!R[BW
)9_-%C$c'BWr.`O#(a/_Y9<AKTW)03lf5'[WtS9hZla;eiHAg3N>/bLrhBU*AM%n+>XNhcq%
[Q@CLg/M'8')<FuE0%P_qc)kXG;XXLW.YShRHoiF<-3mCr?e'SS_u#E^]A,p\aLZP3iWKuKo4
3koac)+PoJ`&8nEZUrHeb+?5Scd0Wg/=-dWr,A!VBL,A'>jEW'oPma]A+<P^io5g%t-09cZUJ
l)es_s[!sViSK58GTVtBOf@5GQ'RA)o$gkKB0l8NMl_/shhV&&(a"BpsJIcXQ]AbE"9=Dk?SZ
UlI*,aD-1H%m\CJ)>H8>P(Ct'U7[o=me"[MciUh0&2h3G92[T',g;.#SiaWXH2NV5^_tLJR=
(ZJ+V.)WdB7WBT/RC5TZK,()<Yl,*-!CSqD[^PfLDA?U_c,G.5I\/oT&\rha!g/LX<QfR.s.
T4u,=4DVe'%f-`9k's.>2H$'^*d?"&OPS?2UfZ^Sq=&1_Wt37hFVr2&*q&ttTCKrKdMhjUJG
=4R.n&@Feq(W1/Q""IHJA`(I(*3mn3F.GBt"j>H?g:[1YkRB_8ZY.X.Wk%\,NOTf7K\t`n`"
A`f4eb\0PSf8Q$LIUtkQ1hYYR@N_Uk-#*15I90dcQ"1K>$;1J;Vju0YCb[Eg:\l7<@T=&KJ4
@G6'HCD:GCj(S]A7J!bu_ulLoVCj*>6qqL%)6W#S\9PBdIF7CiEO/QC$-&pjP(PNUKf]A-PHSr
Xso:45CLY>]A[U4nH8d$YD&3`TV%WkOXD&jnm!BTk6E>%u^H:6L?OQeLh"A)I'2l;<E\qatZ]A
,qPIC;LJ0/>8Wi@fFL?8SB]A-qiG/uVLY6_tacO12]A./eLeHJ"+^h/LUN_>7l2^XL8OZA."/A
smcXnpY`ffsN^gn+-@V4J)n3o?"&a1jP"Slofk_<JCCA6G]A^mOl1s9$#A@k`8s8CKc,>U'WE
XhXc0CFZX;pj4'(%,IV6Pf#p.BOD>81mH$Uh;p/U(*D"p4c0GQ*)bTP*R0\EHgT2OlKT%OrO
$66t3Ehi4+j1DbUdph3U3N97Kp+s36d(AI4pmELB'\!]A1*7/!#O]AC2L9<hV*Aj*Rdq;R*$dI
io-?22%"dt;//3AQ<DA0:5<5kq662m5WBKtA`mP)nD!@t2,eW=G#g!%s@DnHm1OQ7h1Y0TV:
;;hqQbKoYO/r8O\\9CrO3?;*HH.=&ZSY^C2_o^0dMnIK5nK"V+?L`E.&F.9QAdU2;lpko.M+
lT/`oGLu2!>kD%eDpjY1P^g@lkN;fr\@o7XgEYIUOSJAD`#-D]AZ&3]AZOABT:%Rp^3:""2IV=
4Gh^!FJahsrct]A^V%c5P[lVuN%!Ca\_/%4b$#b7,$g[kh6$n.]A[%biJs3CaK1-0dpgV]AF$fd
,l)3nf/Vcf1:Dd4EE^6:t`a8GadPPZEcNjg/I=GP4JNm`m!->EH+T.9.J;oHZ_-6'?aTkphN
=raD2d5ieI2I^NP45B>.qohH'U;EpJdjQ@?dh!GG[,8_'cN4%N`7]A=E\uRBMG#dVT0]A<&GXl
j%bXQRgk@0F5i7CRaGQU]A/;=Lhr%P_F`j2",%fudE!S$7"^fHf0)Eq6IR^AAdrEk)'/4pl(k
X:QmL/Q8@JMHU?]A*/<.IA^sc>PE2c>Vi#^P01OK4XM"emG@[LiQ.H`<aYn@oU8J&g;gDLZXH
4E%bk%#XkEW`96U$Gm_U=FGmZr]A1G1FN+:9RA!"_O8;@u*Pr9n5m.SLNXhc5bk`^^fC40VR#
GKP_W.am?9,bC*BNsO)n5W':F=('<$[m,g'GZ[h&58eopF[m2R9K-#]AYi95XbM+)G.2+`'n*
f<c$h&m<36<;XgFhJ7N.hb=^?stQ<N!2>h1f90q\'X4_?'sR63@PPF*cenIIE_)5DSULA5i>
?O%eM&MTi'm>9MDq%67p-%E^/6lpeYYOQpNG("?1;G\ET3.s&ToF^r6"/D#2c"CRUPd>'Blp
$@M0"Lg>EFI^GY3Z^JT7R4)E![q&/t?3E^a\q:VP`-<F'4&S\fnK?ZY>7^jFSsM6CHjEMe4W
7GQmiA:&kZ'J2n>V\uN?M!EP9<7oGs&J3\dUa3ci;]A7Urg^@@lA&3G$97st$10oRqVMPrA-]A
`U'%Z!XJOGg(0UTr!h"l_Hf-qGnXt[ZIX-4M2pi(?O\h;e1cPZ`h).;TD=c8BI+e[Ht?f`JO
@7m1dRR/A$g+H9lP5rDq86L=M3Y#9"`4;6K5FOefIJkf??hn=(\!eLV(Z`/:nWKMt!CU:c1u
UlPqm<\cX;c+ce4PSdqrZ%790h(9m_nOM@0DK\Y:5'+e7E!o4F",XcT\($`Q9qdGUHRmhmS^
0nPkB-6eDt^[6SuN0&6/UDsl<b@n<e@':_Koua86Bb8D0>;KC6A0,;0f3Je@QW>1K`+Da;kc
NgN@tBbt$>jZjmGD-eGQcV"52B3RH?'8I;iqkG+&o_#5=.dWj/cK&9"c,FV`*f`O0AaC5i&F
h[4(cfD-DH;E"EC\HSKdAQZrHi*t_$8m8g09^[%]Ao`CF%YduOT)+Vke;*M)b#1OO0PduY/[e
"d^>*mBjmk5W7(ePd6QTBuONq+E-I<d.d3mtQN=f_/m]ABPp7ql>ARX?e0a9q7[/;j=)L%3uM
nV(OJbUIN'99G(<jUb;t:h8u[>]Af-E,JKrS,(sheXSm'uE$Jsb!jhCD8PJmo,UD(u'"6,rg1
cnVcC4mTds<1<8CGmkEbYs&FObKOeDQWhWt$C\:kZF_Cm$P_7GMI)l=AMVA91-Md0dF8gqt9
n'5bd%Q=lrO?,oqAQ!_b5>0Q*=8uojJ9of!^UQ0p?#%#qD,4,+p($#V@FH\B;k1/%pNegFF*
riD9ht#R'[t_KLQ#`jMlQO.9a9NRc]Aem;t&V)Mt><ACJENr8^\`dE':lVb4(miBG4")e#kb/
N)Z1D<BE3oUU*k]AZDR22F.kfCEO>aCupqOej#9;Y[h[fs<m4E6;T(VN[&@*U.o*K#jbB]AA&h
e*^opGrRqFp<\5I/s^&MF-eFS\F*B).iRcP:p4e3lb\;@`'/G-_9?p/^pJ8g2L@UU`p!(@\K
9(S'hN`6!>4.)L#lnRlc]AYB^:HgV$4Q$f,VV&^o6Wr#2<JArPt08BNgcL+JRClp0ces]A<X)@
hGZ?:+7/HT`=TunUf'?\J1]AE1hgH>TCYd^Rbg#7GARb`rSU^g14Ef;-A"ru[%Ti]A8:iO*G<:
gS]A9f=15<kXtIh)=@c>4E\GHF\=j\Wus0!DRpU/;-lh!Zfb3q&`&A/6qsX=0(FIJ'Pb;VI=B
2%(6L&6mR?n>=/cEn4_Y35G/4Ya:MQIHcMN4)<EC5M4bL`&0@>`Y88_n*3k<\QC8gKh:U8*%
r;.//%J9nIMa&?uDg@+Leq]A]A<ofNQQb9?Jt99[H:`C)!@"?il'H\hj5)n5f,,N@H#(opo\F,
Sp>-hT$eJ^_^?&#%j/<^G''GX'le\A6)%\?JE`.LW*S<I!NG^(9mAbVqV?[RA.p'GZ-bHL9o
QYsNGoB)4tSFo]AE#H6.q95/#H*I[W$!EFQ8indc15Y1C>1QJB$A+WlM_-d\.p1B3V!amG;@Y
ob^3KYe7:atLJYBF@eg]AcE@(]AOqkbMJYWhA%q<3+_LB!&``0?O%@r'=C=Zr8XGnE63t]AZ]Aii
(r87SOq5X%Xh>MAp6#TT'8T[I0i3Uk=Y80=AK12\(WE#Q:\:90:qgO#G\kYFnSV<UP#[kr+O
5;hH\d5XUc+8eR?%,?*R/kLPgn'O6$!d0064[k([hPB+V0)A!o&:,**4OkMeAA0nZ[L]Ak@Eb
M4h@275gq2;bkd:+<t('47tj#f2:HA61Yk(&[CrfP^.4;>d;YG[ocj[/,+dY8?g&0&<n8#pS
3RCQ\&=W[e;Yt)D/`4o0T]A&s[9ZJ.<cV;CUgkJmZEW1)u?%;0Ypq?(boG?!?@S)YRmPRS&%0
*3jtde>8\"Ys3e'g\)"m@-1"\el'RU^imNlTHk!Y#7.C(;L/"@(6,DAZgnl>s6"?`gh>gFtO
;iN54D3;)?Z0>[6?agr\CO84@;/*3gpEUUene7<Q:?QEHiE*)\'eh\t;AT@E'B*<()rLMsBB
@ml!b-H\)j+rT_`dI#L5"9:k:eBFnXOuf=;npaQeQ\4E3Y`>Z.'_1Pl*R%!_,l`@]Ad<BK]AKC
aW8EVL#`_.,Dl=NQ?4PWBsm>!U\bWV$EF:'!2@-,jI?M:S*K`D4H,[Cl7:GmgD:L\adkVGVm
NNHbkjid42tid\[b@OAu'*m6A;Yh'k"ck@cJ"OtN`j``)#6lH=Om[K#.M%YE7q80LWhkntRD
\Vm3eX"Uc&1k;KAL8sD0]A0+8:jjeTcQ0MT5OS;o2Usc@-_+-c@1J#]A)od2]A"L0cGEUj(cm>$
i[Y!l\lRp-h8<-4"Se_.A7$\k`RQl!nu>^'pnlq["qd)DmL0@SXK4kuJ3.!Yd)H<A\MB,lPd
V=am1o!@%ESDTiWr,bTMl%J,P\#UV>#/kZ8FKsXal-k=TM?#n91tfe,eM]AR=?a=;b^o?aHJ1
q7Y&I+)t!/Goh?pe(".W*1CNccd1kUq.)[>@.Vnq<)NCK051!P@Y(8m.3jM%ToJm%ahP*dQ,
/B/L#BrT)RjZ?qMoj8k8_b\d=)**d=$KWU*3j":EgeTB1C:>.NJPP(Q+h,mVrD`4&WjN>Q04
5<:VBaRrs,k\p5'leGHRD)@'&aD[t!O3aoDkbpfk:`3>P#dc,V3n%jj=\>q5DU`KS*h(Bqfo
]AEnsj8AoUJ>f!MkBoRp/%l38/k+_D<=kM0EK5m7rJLR8JNc"/mD1X-*a$*1i\s)CQ0B0=*TX
D/10C04XSdV7CSRh`ikc>b?2ucRCnKc4ia@a,HLF.CV4$+1CSBpb2;KnIQ'd-"@,A]A"ufl'g
`i)m0tpCZ>!RbjGh)_GGAXhQ:RG,J0'l,G%FE;*0D\bb.%QgW*?Vc*&%4j`K9VGQCiB08\c7
sV239Y?"2UFQ9\d6reEbCrm-->qk@*b$$Nd;TV7OFMb!j,@1uj6[jT1mq5cl8cfean!5)NVP
6uns-*L2sXD?EG/1=pQUtc1?<AGmq(M)&*_8fX:lKSDq_rgYAjrM]A%Cb:[`CPmC\pl!W4bNm
+aCl$1$1+V!bH!?Q:Eb.u-W-?]At"TWl9Yo;/[akCAk,7r7RXL9/?3VHM0`hq"0CTOU5`H80V
cDBo?Y&;F=Df^3bk'G[qeYBU,e_k&BRB5A9HM?5d?9l\h8)cPTn.s1<]A+ZrY<ntW8C`[K0bL
(0B(:$A88hNlr02MhMnVi`;C_d428`0;8[CXH+PD>LGUi&,"(ZT(j*O\[=ks9_p!ZLHO6Mn4
Io=^HnM0-meD1bXBPl"O/rP<@o7fN)S5']A<dlrfS'*4F*OlnrdLr*T$>U<!`4Rg2!u>^P8kf
utZ!0RkdMk0*>5(M4K[Y(W?!gjcnEi@D=m%iVu&iB=?`^=[Yf8k9@*bbRgtVeO&^,'c=Vj7r
<?L-oX+rLIUS-ap7V*X8'sP<QVn]A<N+h;^\hIFfJ`.3"J8&M*74TdHX\,d$2uI(L<(?"R#0D
ZE/T;:]ARLY&-.nu#XJ*PLsoU#H:_GRm\(T;nCDTW\>t?-@9<m9OCFM&r4>oiFYFP\#`rSU8O
CG]AVV5rPQel&lYmr?;J3AcJBQ*-bF4($<3JGP\S`(g<Z2_DM<.ZW)$J/bg$oc:ABF8tOC^Bc
`%S\V#nF`Aj4g]A4l!L+]A8PQ2AeXm@!9"_HftQ[B:QhgnncR-;u!jHXD2Zp8t<kImUeh9e%E9
5h[,9mlnK6X1<@%=-9eiu4O.MBkYO9"7XtaE6'EV2C7,_2jo=,5o=IQi56V^/F!STTHZQL-B
Umc+G7AC13/Wplh%,<Is^uK7_G=6K8BDa4(Z7n96a,+8`k_EqPDM62B#Amp2m`/Ll!t(3!LE
mO9%7%geQINkFF[Hu6[@7aR'f)1Je"2:(eTXQ=QCTEc)M1)U_^N!Wab4%``5]A+nP7VbFg[Z<
9*rZT@$"/1hAWlSqF/nW*a(*]A:(_(?M)P:s;>6Hdmn?g)3Z?*:M9G\,]A4kXD*1!i@e(>R&>4
8@:q1X<*$#`>)/+@`pX->Y"pfQn['p#\GCj>e3UC!?N7Mk<*Y;up#;M%1;\c6)0VE1S=WH;*
in:_!FXX:aQ[g:P\r5@q-O%#8Q0j2=6pIO`K\$2U72pq^DOk#08Grs43-0#6reZU:`2Rl#(5
$sk5bqWHJLh'-MLnp(l8]AT??."/hFPd2&CHKb'..MTZMXGm#M3XAbm=ns`q;[.l@/M,1!pl2
0WEqK%EH1SS%#p1X/I%6)J3l7LH,#MdcRrp99&FT\=jU+KnZe6qVmh9U*,C=qT4Ed4-7UL/]A
pf"Br[6cL@_ahh%G@Y&i+hL,+\2<o+$YI8=2?--c"[))mHF@NGrq(\C&)X@$e=WK+J#Lf!8H
YA7d8J$Ej/`Z.oJ28[MQZ_Tkt$"ZMCN0DK>7J0:4.]A\%m4X7(q$V3MBB5">CUfn92Y=7bl`T
4.^/e3H91jMmhVO*'sg&X8=f!*G+j59q)fV!315Pc$2s/`f"?9VL-D25W,Vke#Cg):3m*lPJ
@m)rf)k58\C9gY<DsM@KC,5KHm3MOtGHf]A)iAig%e+V=$&CMJg&#"84iVC2NZ!dcTrl59BKs
jg&WdC^\/RWiI_%.-]A]ATHk#=aIb/t<R\*ol255l2gZ^uE\`VOpa;Af`b`h6XD5lF7r-"rdf!
=Jml<+:gW`lm%?Nh#F8V`7"50P!Um2,MZ`,j#e@":?rK=mGGAeu]Aa7*4!!FlT3<du]A.Wp8E]A
TRZk*03d1+"\oh\<Z]AOVolZbGI/%REsaU_C"6?kp?o1Ra)q,W[VD'F!.[E.#?V7&6KP`hl+b
Io@U&*t'+KNG>%R;?#9rc6<RWKfm]A1JCc<%uP&!C2=j,YIK.3,O)$\kF-O<?X'Ua+Z,K+93=
=kD,4#+,/aiNgkQ[EOYaE>Rd[+&l5?R9AkM,72F<ZYh:Ks?2_Xd0]A0'E&)jIK>XO>+7'6WRC
@FK1/1*g$Y%Y;VoQ.2\q93mm($-,/]AFl%LiqQ#=4Bf?*3N.KW4f-%"<POV!73Nb`W7'7^[g9
j$qk/46>.nF.AS5^uX[SXk4Fl-M>C88$2E/dc;nr8$mfm[35pLlX`hu(BN!C^7".JLsR<A,Q
s2IH5b@#PIkXh:i'Fr-c2Z!>%Wj[jb+R?GbIN2#n@TcjAfCQ//J,P*Ds)3qY=_[l0\l58_I[
gbKi1JNsPimp=fnN:r(]AI#U_3_V.jDn^m4fWX']AkWFd%bm]A%=+'p3Jc\<0q5Fo!#dHgSt.+]A
A?4kL$tR(Z*h;`NZ:mZtleacT0T4GHP/FWeqD2sqUu!iNdBHOPu@btuiEq@+iS3\/EOD0.)e
Sr%cH5_'q@op`MG'rG9$=`"JI\T0f]A@']A!4-ug%P[6.-[i2cjM)@["0l;Dcg_O*_rg78,GKT
\(JZ`\W"9BUCs&oM4No+8H>ffJ*pB`Crq,C7S(PFVrP\D4:aV^!e-\R,s^qV<),)T_S(WFCH
$1h$_T/fP@Zg4Acms5njhbg.i%!X[cE!\e"g,DHCnotU*RTRC0d'kKGsEH#ln<AXVOe>\j3E
l[<(^IHM6PpQVZdg5go'=$^IYK+.3UbBi;URI<nJ2HIoP@>>nO.:.h5OuWRDE>1bK"1*ZI:$
+eJP^BF^i*'M/$Rud)K2aO1%gXXoK_Q`5#pWN+?;DA2=_o!j<=i>1mtB/InnYCYR034(q)Q?
Zb:,ud.u!$5irS9qufG'*9;2+6D*ClW/\2^dpp#2NSF,-)"6qA<dCY5ogqA!-??=#_7[\Z*F
fi2qlEZ_9bAcn[k0!'hlD-P^`5,&mZ<tHH%.#SKXkNB=;kcNDt)\moA*;r)Ab6Yr:6;&(S9U
sF/+4jpV@\%TC)l]A@%Y:lb)3TEbp96N#Z3ZACaM<Lcnq1Jr2]A6jc,#.bG]AW?@L8W/7dnTZNP
e)*NBmq=2s3jSde/We*dq<dg2%ac\D*,]A$%WWL,?THdCj8VWF7H=o>H%/@#D`u,=f-0.J[F>
-]A&$Dc;EPM<@p""YDFi1EqVVP7\j6AG"Jqf@DOHbYGd;(3/m"pcEJt-6GnATfLfrG+K1uo"X
7<bR71WI$hmJ1%XGSc/VS0#/>1*N<+M/[4s!:#b^2\hhm%sg?4N>q`/:/&d\[D"r_Cg2Vn/K
1/(cu%8H&AW7:(2>E*BtZS%MYPEM_#46G&;]A)tc^tr.!<jU&jG1`:U0@5#>"_j,8A[$;VZI@
Ak39%A&ZkNhoU,;CamT\`L:<,&X(0^/g4;.,?iDCXPnuD1;!`Oe&;:u*K]A:YLDL,G9lGEXDn
9D2V$n-PSbpsUpQ?lG+SCK>K6'q-t_8&U1>mg)SaVQM_hk.6$8WTc#"J!=g2F+<1hA/$&(3T
&5dA`q\gdG57[EV,'V0qZC7H?(KRcr7^Ap@kFM=["2!^b$&DiPLF0I@tm6h\lK^)$!p%0%(9
=>qh4irr=DSbr5@""q;Y=ND7#cS0l3Ke,1l5='gt!%<T0C*f;A.V2bQY8<+gY&n?fd]A*a95\
8mbNNN\nMlm3]AV$bFVq\@.%@S4_n&tb2Q(_"B[=kDdcf<4?gbU'kpmS0#nCkmHq["(a"+?]A_
O'G%`/_.+%t$h]Al57L4,9bnKM>g(G^4X]A&qZ4k>Q!J--QV\'t`-o4P'J<Y(+2b(]A_Ur`%$<=
XMS;0kp`4'C_;\<L'UVJ$%9X[W$cHGI82.MX[E)QmMe]A\m8<M+u"5N"oqL+aVlI2NkA?qT=s
[9R@OD]AhOVG%>JZtc:M%\ZlU/uI@C-BhJeLdi[pieA'EgG=OSit2qMa^TE7K-(rT436p8J8l
NS3=<jGUe7oa*J1Wtk#PW/rM"=tCR*?_li0LBNPJJo?ZH+qfOd8&?)IjRO7,Ub4\r+0I<J-L
cu+CM^F]Ajg7\;KX^T8bfgEEEj6R<HD]AM<"CFFlf-FtDTinbXq-*k3WV7Mea-2,!?q"DNYAL2
kQ2t??1)sT(E]Akr"4X"=>PR&WOrd?XLaeIJ3[sJ%Mo&"M)(k*u"DSl._%0pP7K]A/:M[nP):S
36@LF`%J"Q,/4KQg2S0nes[r-&<'_!9@6TDbDabs3gq)=>p-*(]A5XE"[]A`2#'"NG)+%[D5MY
<j?1C4knK(+q<X88W%rZ%g_i1Sn"04%1O7E^<0r((n9(`+oloPtkk,al<eWJ%1!1m0()LqWk
KY'>-*@B?E1a1s1$'ig/-P$*;Z2K9T6NP$i8<`.)5RT!\;a>+fmO9dXMlnZmM37-XMD+<B8/
4SXg(AhLbeYPN[mh74Z":m<KN4neY`55PD661%+m`6DXEK:ceY?tMZUXR]A!G>0I(L/WcC%VV
&5-M00aW=PLK8ii.&2]A0:=jb^b;%C.[Iqe+Gd,0Tf=2!3f)9uU3n27'8)m'(NA&FkSnk^3""
hi@@Rag-8&nu8`X.UY1:2)L/.KR,.$d`HCrLI/<%'99#8-<;a;_pR43JGJ&Op4-T1IaFBbYU
Tugo6M&7XILmkcn'[r6E9I#!I71k)U;lT(cM'OZ1HK_1><ED^-h%5\)n%K:RY<`X;H&?qdL#
cbm0dXN_XFBaf=ej=h,COSf<If#:RVM`#D>C8F!]AP3rnu:"#mF]AnlG6BW]AZ+6Lg,n!Dr('JI
alpYn'+(V.(K1j*i4_VC\^6'9aTkYLr3Nro04d)s6fB7Xe74oW'4f]A2s'YG-1Y!8&86jb-K1
"_kUW4FAA>^1Uo1`@ps2mQiG_drl1grpLfF&7:Na:2l2^pH0s2QQ$UF3T@ZW,$L;[h=f1#@Z
Bk83cSa:InsBJ+3k0oK<#a2\e="&i]ANI>9[qp9m4a7o$:nV=Cs0SVGbdd4CWN\JhGm\@*Aj7
2_Yg$jRH!/NG5jI:^(H*:`SA6!q`nLbp'W/-RZZU\HmCKZA,4NXXUog_)L]AD;hlGrrK\l=*?
:-fN0D:ZJtnAmXrXDQBS?E7!2(mW?JrF`n=SYm1'4%E=WlNu<XgAPa/R2uWQQ[O/8RM>4BBn
AT0T-`ig:J/bh/BNdrS]AN'JG"O8[)Q7pHA;b&l212M,[4Q4<l"Z9RFoK`m(!q"!L32_^p+g_
!ZJRc]AFjki<4J@Rg)m8?qIL$Y23_+F01uNtuWhB(u]AF4-W/Og0ES>ee0It.@Q*p_d)9lETAo
NA!D_C/M[R?lNdeai`oEiC5+3()]A3,0n!i<p/$o<m;VTBb5E1`V8h5_R2hug@XXd/O`tT4V0
R2j+<)AG<1H"=dg!D0''XTdaE?58gEGQd8.qq1+UFeRZC;bICF>[GBN-Z$SRJj@XQ%&^9ZtW
!J]A=spIiUb+gZig8W>hhb3s1,$Vj:bXOqIkpc[j2YWkR`505IIg9U1QG.qh\*S(<;9jkF=UG
IEEFsCmAZd.C4UT";B`Ec_%TL'LgCDM"E_FD*<oRrSHFrbD4`c@hM1:u1i^&H2M"a.!NfRc,
#^+0*S!e>uV*Z@6>Xo>)Li!CNk^Q"`>@]A/]A>c0hMhHj4H[k$?6c7)e0_k5c"2jY/79D67s23
'OZ=Ikg^bAAAKF=PTJQ^L5r50R(TJ5b-(*]AB3f/[9<R=gR.ERc?IG%Bd';loReU%9u[^HA;=
mi/0bD6eQZ85'f<o^Y]A$,_g4k]A"lomMN;!jW_/,Rp%0@n[N=Yh,!iTalnUI-b<b;c+C1FqXi
'']Ao452O%lpl.j[AB+g<[Auq0*!A"%b53u4fD!AQ<6;SO%;T(&Zi:G_1]A<S2qf)/u=T<p8I$
W8P+CAE_2c6-63?Vc9;3>m)S(p:Ydp(2-@[Md8X:/Y]AUdSlcZ0J*W7NX#H5Y@K3m6NWWQlj!
k8lQt,i,<UX$s-*>,dWLD5,hudF]AZPdZ'S9Qhg%$O*/rSg]A]A"4+6N9qW9QP18U3O:soMd+7f
n"Oj'^MA9rd34i=0<OVKVX2JK,?5;:KmNQ^@a;P\NXSD-Xn`o*Z"g#QjgCWj?2qrZi[#WQ>.
7&(sUg2&?!7.5Y,8RqO=&G8UIB4:q&m&B%Y*nRc]AC0.fmgelik,t^P%7[=XoXUE?RinHF2%[
1I7_D,)dW4[Yb'2CMMc&'.p(JB4Z<d@_hYIFd[E.@uNg0*4P<s(Sh_*2/OM%N_L`A_3na#[;
X/@Tm*'<?SIOl+*n=X::0p+HkC[+HVn4Li/<qLf"V?[[<p-4%liqZ]AE"$s$-WeTS[CDi,5=9
p>]Aa6?q'=^@O5TV*o:P/0c$u2^2#h:he,6->:\14@5L"\Hs"sairr4b2j?o6*I/!2oO)I*+X
pYY<Q@/Gu2WMFHGNM-6PSLr[q`4FmnE8`U_4Q?E#Cd6_*;hhl^HSUGDmA%je"SEZnDBLhQ5?
PqDr1LY~
]]></IM>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="1" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="426" height="91"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="245" y="57" width="426" height="91"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="chart0"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="chart0" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ChartEditor">
<WidgetName name="chart0"/>
<WidgetID widgetID="34b650ea-5853-4699-9939-7fb407acf481"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="15" bottom="15" right="15"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0"/>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="黑体" style="1" size="128">
<foreground>
<FineColor color="-11316397" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Position pos="2"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LayoutAttr selectedIndex="0"/>
<ChangeAttr enable="false" changeType="button" timeInterval="5" showArrow="true">
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="PingFangSC-Regular" style="0" size="96">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<buttonColor>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</buttonColor>
<carouselColor>
<FineColor color="-8421505" hor="-1" ver="-1"/>
</carouselColor>
</ChangeAttr>
<Chart name="默认" chartClass="com.fr.plugin.chart.vanchart.VanChart">
<Chart class="com.fr.plugin.chart.vanchart.VanChart">
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="true">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-1118482" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<ChartAttr isJSDraw="true" isStyleGlobal="false"/>
<Title4VanChart>
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-6908266" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[新建图表标题]]></O>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Microsoft YaHei" style="0" size="128">
<foreground>
<FineColor color="-13421773" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="false" position="0"/>
</Title>
<Attr4VanChart useHtml="false" floating="false" x="0.0" y="0.0" limitSize="false" maxHeight="15.0"/>
</Title4VanChart>
<SwitchTitle>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[默认]]></O>
</SwitchTitle>
<Plot class="com.fr.plugin.chart.custom.VanChartCustomPlot">
<VanChartPlotVersion version="20170715"/>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor/>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isNullValueBreak="true" autoRefreshPerSecond="6" seriesDragEnable="false" plotStyle="0" combinedSize="50.0"/>
<newHotTooltipStyle>
<AttrContents>
<Attr showLine="false" position="1" isWhiteBackground="true" isShowMutiSeries="false" seriesLabel="${VALUE}"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
<PercentFormat>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.##%]]></Format>
</PercentFormat>
</AttrContents>
</newHotTooltipStyle>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name=""/>
</DefaultAttr>
</ConditionCollection>
<Legend4VanChart>
<Legend>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-3355444" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr position="4" visible="false" themed="true"/>
<FRFont name="Microsoft YaHei" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Legend>
<Attr4VanChart floating="false" x="0.0" y="0.0" layout="aligned" customSize="false" maxHeight="30.0" isHighlight="true"/>
</Legend4VanChart>
<DataSheet>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="true">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isVisible="false" themed="true"/>
<FRFont name="Microsoft YaHei" style="0" size="72"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
</DataSheet>
<DataProcessor class="com.fr.base.chart.chartdata.model.NormalDataModel"/>
<newPlotFillStyle>
<AttrFillStyle>
<AFStyle colorStyle="1"/>
<FillStyleName fillStyleName=""/>
<isCustomFillStyle isCustomFillStyle="true"/>
<PredefinedStyle themed="true"/>
<ColorList>
<OColor>
<colvalue>
<FineColor color="-10243346" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-8988015" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-472193" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-486008" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-8595761" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-7236949" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-8873759" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-1071514" hor="-1" ver="-1"/>
</colvalue>
</OColor>
</ColorList>
</AttrFillStyle>
</newPlotFillStyle>
<VanChartPlotAttr isAxisRotation="false" categoryNum="1"/>
<GradientStyle>
<Attr gradientType="gradual">
<startColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</startColor>
<endColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</endColor>
</Attr>
</GradientStyle>
<VanChartRectanglePlotAttr vanChartPlotType="normal" isDefaultIntervalBackground="true"/>
<XAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="true"/>
<AxisLineStyle AxisStyle="1" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="3"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-2500135" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="2" secTickLine="0" axisName="X轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
</VanChartAxis>
</XAxisList>
<YAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartValueAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="false"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="2"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=10"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
</VanChartAxis>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartValueAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="false"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="4"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴2" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=10"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
</VanChartAxis>
</YAxisList>
<stackAndAxisCondition>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name=""/>
</DefaultAttr>
</ConditionCollection>
</stackAndAxisCondition>
<VanChartCustomPlotAttr customStyle="column_line"/>
<CustomPlotList>
<VanChartPlot class="com.fr.plugin.chart.column.VanChartColumnPlot">
<VanChartPlotVersion version="20170715"/>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor/>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isNullValueBreak="true" autoRefreshPerSecond="6" seriesDragEnable="false" plotStyle="0" combinedSize="50.0"/>
<newHotTooltipStyle>
<AttrContents>
<Attr showLine="false" position="1" isWhiteBackground="true" isShowMutiSeries="false" seriesLabel="${VALUE}"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
<PercentFormat>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.##%]]></Format>
</PercentFormat>
</AttrContents>
</newHotTooltipStyle>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name="">
<AttrList>
<Attr class="com.fr.chart.base.AttrBorder">
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="3"/>
<newColor autoColor="true" themed="false">
<borderColor>
<FineColor color="-1" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
</Attr>
<Attr class="com.fr.chart.base.AttrAlpha">
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</Attr>
<Attr class="com.fr.plugin.chart.base.AttrTooltip">
<AttrTooltip>
<Attr enable="true" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: left;&quot;&gt;&lt;img data-id=&quot;${CATEGORY}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${SERIES}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${CATEGORY}${SERIES}${VALUE}"/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.5"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</Attr>
<Attr class="com.fr.plugin.chart.base.AttrLabel">
<AttrLabel>
<labelAttr enable="true"/>
<labelDetail class="com.fr.plugin.chart.base.AttrLabelDetail">
<AttrBorderWithShape>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="true" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
<shapeAttr isAutoColor="true" shapeType="RectangularMarker"/>
</AttrBorderWithShape>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
<Attr showLine="false" isHorizontal="true" autoAdjust="true" position="9" align="9" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="宋体" style="0" size="72">
<foreground>
<FineColor color="33023" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="宋体" style="0" size="72">
<foreground>
<FineColor color="33023" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: center;&quot;&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${VALUE}"/>
<params>
<![CDATA[{}]]></params>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="center" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#,##0.00]]></Format>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
</labelDetail>
</AttrLabel>
</Attr>
</AttrList>
</ConditionAttr>
</DefaultAttr>
</ConditionCollection>
<Legend4VanChart>
<Legend>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-3355444" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr position="4" visible="true" themed="true"/>
<FRFont name="Microsoft YaHei" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Legend>
<Attr4VanChart floating="false" x="0.0" y="0.0" layout="aligned" customSize="false" maxHeight="30.0" isHighlight="true"/>
</Legend4VanChart>
<DataSheet>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="true">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isVisible="false" themed="true"/>
<FRFont name="Microsoft YaHei" style="0" size="72"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
</DataSheet>
<DataProcessor class="com.fr.base.chart.chartdata.model.NormalDataModel"/>
<newPlotFillStyle>
<AttrFillStyle>
<AFStyle colorStyle="0"/>
<FillStyleName fillStyleName=""/>
<isCustomFillStyle isCustomFillStyle="false"/>
<PredefinedStyle themed="true"/>
</AttrFillStyle>
</newPlotFillStyle>
<VanChartPlotAttr isAxisRotation="false" categoryNum="1"/>
<GradientStyle>
<Attr gradientType="gradual">
<startColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</startColor>
<endColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</endColor>
</Attr>
</GradientStyle>
<VanChartRectanglePlotAttr vanChartPlotType="custom" isDefaultIntervalBackground="true"/>
<XAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="true"/>
<AxisLineStyle AxisStyle="1" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="3"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-2500135" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="2" secTickLine="0" axisName="X轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
</VanChartAxis>
</XAxisList>
<YAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartValueAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="false"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="2"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=10"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
</VanChartAxis>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartValueAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="false"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="4"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴2" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=10"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
</VanChartAxis>
</YAxisList>
<stackAndAxisCondition>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name=""/>
</DefaultAttr>
<ConditionAttrList>
<List index="0">
<ConditionAttr name="堆积和坐标轴1">
<AttrList>
<Attr class="com.fr.plugin.chart.base.AttrSeriesStackAndAxis">
<AttrSeriesStackAndAxis>
<Attr xAxisIndex="0" yAxisIndex="0" stacked="false" percentStacked="false" stackID="堆积和坐标轴1"/>
</AttrSeriesStackAndAxis>
</Attr>
</AttrList>
<Condition class="com.fr.data.condition.ListCondition"/>
</ConditionAttr>
</List>
</ConditionAttrList>
</ConditionCollection>
</stackAndAxisCondition>
<VanChartColumnPlotAttr seriesOverlapPercent="20.0" categoryIntervalPercent="20.0" fixedWidth="true" columnWidth="6" filledWithImage="false" isBar="false"/>
</VanChartPlot>
<VanChartPlot class="com.fr.plugin.chart.line.VanChartLinePlot">
<VanChartPlotVersion version="20170715"/>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor/>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isNullValueBreak="true" autoRefreshPerSecond="6" seriesDragEnable="false" plotStyle="0" combinedSize="50.0"/>
<newHotTooltipStyle>
<AttrContents>
<Attr showLine="false" position="1" isWhiteBackground="true" isShowMutiSeries="false" seriesLabel="${VALUE}"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
<PercentFormat>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.##%]]></Format>
</PercentFormat>
</AttrContents>
</newHotTooltipStyle>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name="">
<AttrList>
<Attr class="com.fr.plugin.chart.base.AttrTooltip">
<AttrTooltip>
<Attr enable="true" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: left;&quot;&gt;&lt;img data-id=&quot;${CATEGORY}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${SERIES}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${CATEGORY}${SERIES}${VALUE}"/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.0000%]]></Format>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.5"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</Attr>
<Attr class="com.fr.plugin.chart.base.VanChartAttrLine">
<VanAttrLine>
<Attr lineType="solid" lineWidth="1.0" lineStyle="2" nullValueBreak="false"/>
</VanAttrLine>
</Attr>
<Attr class="com.fr.plugin.chart.base.VanChartAttrMarker">
<VanAttrMarker>
<Attr isCommon="true" anchorSize="22.0" markerType="AutoMarker" radius="1.0" width="30.0" height="30.0"/>
<Background name="NullBackground"/>
</VanAttrMarker>
</Attr>
<Attr class="com.fr.plugin.chart.base.AttrLabel">
<AttrLabel>
<labelAttr enable="true"/>
<labelDetail class="com.fr.plugin.chart.base.AttrLabelDetail">
<AttrBorderWithShape>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="true" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
<shapeAttr isAutoColor="true" shapeType="RectangularMarker"/>
</AttrBorderWithShape>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
<Attr showLine="false" isHorizontal="true" autoAdjust="true" position="9" align="9" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="宋体" style="0" size="72">
<foreground>
<FineColor color="33023" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="宋体" style="0" size="72">
<foreground>
<FineColor color="33023" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: center;&quot;&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${VALUE}"/>
<params>
<![CDATA[{}]]></params>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="center" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.00%]]></Format>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
</labelDetail>
</AttrLabel>
</Attr>
</AttrList>
</ConditionAttr>
</DefaultAttr>
</ConditionCollection>
<Legend4VanChart>
<Legend>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-3355444" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr position="4" visible="true" themed="true"/>
<FRFont name="Microsoft YaHei" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Legend>
<Attr4VanChart floating="false" x="0.0" y="0.0" layout="aligned" customSize="false" maxHeight="30.0" isHighlight="true"/>
</Legend4VanChart>
<DataSheet>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="true">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isVisible="false" themed="true"/>
<FRFont name="Microsoft YaHei" style="0" size="72"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
</DataSheet>
<DataProcessor class="com.fr.base.chart.chartdata.model.NormalDataModel"/>
<newPlotFillStyle>
<AttrFillStyle>
<AFStyle colorStyle="0"/>
<FillStyleName fillStyleName=""/>
<isCustomFillStyle isCustomFillStyle="false"/>
<PredefinedStyle themed="true"/>
</AttrFillStyle>
</newPlotFillStyle>
<VanChartPlotAttr isAxisRotation="false" categoryNum="1"/>
<GradientStyle>
<Attr gradientType="gradual">
<startColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</startColor>
<endColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</endColor>
</Attr>
</GradientStyle>
<VanChartRectanglePlotAttr vanChartPlotType="custom" isDefaultIntervalBackground="true"/>
<XAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="true"/>
<AxisLineStyle AxisStyle="1" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="3"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-2500135" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="2" secTickLine="0" axisName="X轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
</VanChartAxis>
</XAxisList>
<YAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartValueAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="false"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="2"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=10"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
</VanChartAxis>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartValueAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="false"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="4"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴2" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=10"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
</VanChartAxis>
</YAxisList>
<stackAndAxisCondition>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name=""/>
</DefaultAttr>
<ConditionAttrList>
<List index="0">
<ConditionAttr name="堆积和坐标轴1">
<AttrList>
<Attr class="com.fr.plugin.chart.base.AttrSeriesStackAndAxis">
<AttrSeriesStackAndAxis>
<Attr xAxisIndex="0" yAxisIndex="1" stacked="false" percentStacked="false" stackID="堆积和坐标轴1"/>
</AttrSeriesStackAndAxis>
</Attr>
</AttrList>
<Condition class="com.fr.data.condition.ListCondition"/>
</ConditionAttr>
</List>
</ConditionAttrList>
</ConditionCollection>
</stackAndAxisCondition>
</VanChartPlot>
</CustomPlotList>
</Plot>
<ChartDefinition>
<CustomDefinition>
<DefinitionMapList>
<DefinitionMap key="column">
<OneValueCDDefinition seriesName="无" valueName="费用" function="com.fr.data.util.function.SumFunction">
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<TableData class="com.fr.data.impl.NameTableData">
<Name>
<![CDATA[利润]]></Name>
</TableData>
<CategoryName value="渠道"/>
</OneValueCDDefinition>
</DefinitionMap>
<DefinitionMap key="line">
<MoreNameCDDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<TableData class="com.fr.data.impl.NameTableData">
<Name>
<![CDATA[利润]]></Name>
</TableData>
<CategoryName value="渠道"/>
<ChartSummaryColumn name="利润率" function="com.fr.data.util.function.SumFunction" customName="利润率"/>
</MoreNameCDDefinition>
</DefinitionMap>
</DefinitionMapList>
</CustomDefinition>
</ChartDefinition>
</Chart>
<UUID uuid="8f56bcc9-847b-4acd-85b7-a4669beec0f1"/>
<tools hidden="true" sort="false" export="true" fullScreen="true"/>
<VanChartZoom>
<zoomAttr zoomVisible="false" zoomGesture="true" zoomResize="true" zoomType="xy" controlType="zoom" categoryNum="8" scaling="0.3"/>
<from>
<![CDATA[]]></from>
<to>
<![CDATA[]]></to>
</VanChartZoom>
<refreshMoreLabel>
<attr moreLabel="false" autoTooltip="true"/>
<AttrTooltip>
<Attr enable="true" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="" isAuto="true" initParamsContent=""/>
<params>
<![CDATA[{}]]></params>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="true"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="4"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-15395563" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</refreshMoreLabel>
<ThemeAttr>
<Attr darkTheme="false"/>
</ThemeAttr>
</Chart>
<ChartMobileAttrProvider zoomOut="0" zoomIn="2" allowFullScreen="true" functionalWhenUnactivated="false"/>
<MobileChartCollapsedStyle class="com.fr.form.ui.mobile.MobileChartCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
</MobileChartCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="578" height="156"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="369" y="383" width="578" height="156"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<Listener event="afterinit">
<JavaScript class="com.fr.js.JavaScriptImpl">
<Parameters/>
<Content>
<![CDATA[setTimeout(function(){
	$("div[widgetname=REPORT3_C_C_C]A").find(".reportContent")[0]A.style.overflow="hidden"
},100);]]></Content>
</JavaScript>
</Listener>
<WidgetName name="report3_c_c_c_c_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report3_c_c_c" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report3_c_c_c_c_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="1" left="1" bottom="1" right="1"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__9BB2985780BA65AD1EEF95B35E198624">
<IM>
<![CDATA[>uh82;Y_49[sY/7bUZq=@@3Qs8oi-LV(>=md7MS^PXTAnS8cRr9UuE+)&5l/=h[R7^`!?pnq
i0:b?2pNUn`L.>DnjPi_,Lk$6/0AbY.,HkFR&#kI]AX?q^n/Pl&_RoAh0ubJj:G7[(gN-#R$G
FhIDP)(9^60*;i)F'-FTbG?@>&E\t*Wr/aokM@/1Q)>VXV5?7?@CRY:_9kYZtV62@DA@-oVn
GRWr1O07LG>t_:cTeT\?R"$)(`KQe",<tI5s,8.2g0Vm&nlQ/"ObNNZk"td@nJ<6_`[C:7<7
kLIj[#qE>?Am=Y*U_]AF0GA=<L2r.4c.@%[i1_1VqBMllF16kJAAK*eWdfE?033,X9D.Bq*<Z
r,bYAlfurr/EL:nN.jI6+6D"nc(k\U5[UTLSlh4'ES]ABhN8BqUDL55aftgDA=bp_hH>DLcO]A
"jFfduJC&Zh_tcsY.ENh9raC&#DkA*LMY=j>7_orPP/22?HXT"K>HG`qZ`S3i+tCQmM8">,2
"2:E]AMm]Aa3]AR+qq5Y`1VMcKuC^dFtBm2qVdi%jS35Qak1pdYjW_]AeQ;a3GTk:Uh5QadLrGVT
uC@Z1)c`;^U>l@@P+@(J\/^$W9[#bE-q;u=YR!29V_;q_mOsI-q;`RjKTKM*l^!8'Vd]A;fbS
Y1<l7a9Or@2'UhWVK+&nh*qR<=%'kYXb4@cY`G`d$$@[+XA%Y)N:P=-(:q7HNfL_r<MF))&`
A>f;8"XS2Yp>WSQa`0%oR)Y3P]A1+n2h*ptpkA"2)0m/jQ*d2a5h6#C^d.m;2i_K]Ae@+KH_[9
l?]AM"NP"J&t`;6`:MRd>Y&+DR?,S-;fh$O51V2<,SCjDW>(f:^9XI]AJP#k3lZi-gASN44,n6
5EATFt>dL;Q.[]ABs]AC7prlR8`3+^UXTr;J=J6*XI:)SL+1I>h.&(p&16o0%=6-["RV/l9Pfe
@p7GDQFV$nTCK=b%iA$UF,["VC$RP"R91F.2DMI0O]AYHnq6)3![M(0C%:Z+d15^Tj,Ze?MdE
;2?YZV#c)&nQS&091p(!]AagAY`/HFd!4e>I2b[`&d7Ce@@51.RFDiRJNZ_PY>Elc%pnIR3mJ
ohj\6Zpa`:]Ao,+TpIKMubQs8n'DF;'2nUZ#-VLem0r-i6[SskC3]A(6pgYa=s8?KKdk>riI81
&]A8;<Z*bpYB81Z2HP\l!UQQjcXC8VIsX8'qBL%ZD;$4=-#qjI38I0\b6OH_YtNRdDm`CQ+ca
kbXn6&,&BH]A#d1r,@ndk(Opf9:<Uk<'U/0U+]AHMt5L1f8Up*#eTj3?^45_g^phN2'.hU:`dW
BkX6?@gNfa6$DKP7(\\:T(Z05Y0,BFOT?^*aSrUs4fn^N7Zc("DhnIqLY3h8_/Ta6,XanNq^
A-O4XL^kE!PJAHdN/Q2h,DO.JKLmW?DsV%j".?1`8:pR308LReIJH@M-\MJ0I%N6L&-8K:KF
dpGj[.i`3K4E>=n2%V%Ua`m65I`Fgr*s%$IHRCg_O/R1UU7?["d,9TZlOJIC:tYl:1IUW)CD
9Kf0B9.p+E4&V;U_V0N:)uE!1.@[dZ->M4q]A?rFnBmFF-<3L<ZgN0d]ASc!QtNa2/CEk@6A&4
%c$)HH]AYPXa,1oi2<GNW.C[L<T1eRl#'=dp(ADRp9kLqH%bO;SIBb!*[SXMRTSCYfA>nUL)^
Kt!bel+YJS=5;1=T\:Z9ZK0U[8sU;T<TrJ@%[JST)4>(filO!UZJ1-E1AibDi1:i3a5%q`@Z
Sj9a7>;,(85(EgQ8gH@(=ipZ4tC5QDU9klY,)kP]ArNpd?Mm^XeqI@.SQHi=\_pLM5FXK25:G
U450B_q08=bWb@sEQ]A+Y'Q+--Cqf-l?B;grndZHqQ0+[eg,6(2I=dUB3#9!0K"9l[J=%-oCa
aomADT5;B0/LC1[1&LfrI(4JltH3Gs#%A!Kb"<$hEQq/sQU%QU3?%RF:#F29Q&0N)JKFoL0^
4-`mBKXbcg3\B-^QYio`8.7Pu@I8pCT#/GHo2jlX!K0(qI3rkd.>i[7P.I+:iSOhRB&Q&C#G
@1XI2r"C82?P*#eiOnM3lB1l3J)B"_S"&&0..BN,m$;6*HBh"-i!qG@uD4#Zs!sc#!EKdZAD
6/`1JJ\[&@B*.A.4<@0<"/1m.hE]AmX_Is*e`-L5Q&BG7cu,R)>JbX:o_\D=#>GT#Os#?4&73
+LCDj$UELchmL7<0&Non0$5<#"6_fL?]Ah!7lE6rd!^_rTPWOI$mr_r[SnBNGY2$PUc0+LP)Q
Ta&jgnTHS5'Meg'#W26\sP!W9gXY`>Y;TS*.DGRDlaAVe4/$Qda[0/d*.U^o8*jejF:`oo8a
qfWmsY56RDPi&J8lY,ZT,Le/g:U=7$e;Fbl4JugS+N&!'XNf-W^:%9gR4^!>_db8H=ESU'Vh
!b.n&F+&Xno1S3qFm4EKnGg3T4_He+cHoq[IF+%4T$>\T\)\^`"i/B5ZWDJbq9K"I=`<@#Q6
NoOP;3raeA"c=oP"TF#hh#f$CHY-e[t*1VS5T9e'tqNF&.c43en5,g%?:Rt%.G_t55t8^&S=
.Di3!%4s"sb#O8nEbc:p&Kp=dG'o+g$R(EUjI7DSF_D)Z*,SP_a14bM)&3sh-bK&=CFIeYoM
/65a5#SI1tss)Eu:!&b5U#[2sg.CGHO4+PT4g0a$/E)=DV;1WLVFMfg?g4s"r&tY\3R2f_>#
js"MJj.TQ?B:mQ%9,'+8%I3q/YFXgfleQuVomg%`-#MEZ(B%W!O[^'#.pZoN-5p2Q2R#,W5!
eHHJ:h="J=;9fpBViQ)^M4>60?BKhF+<%R~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[1143000,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[457200,3139440,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0">
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="1" r="0" s="0">
<O>
<![CDATA[同比分析]]></O>
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style imageLayout="1">
<FRFont name="SimSun" style="0" size="120">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[m?IKTP'7V\T;H2C$`W_d)+%n1OK6T1Oa,'o1+>)lY+*"+3L:EN7MjLY]Ag03F7\gpY?I[I]A-!
un)3jI*'74;1P<.p4k'r?L1.?FnS7r.u4[ND*u^<\gsp\CEDI*O`tS"h3uB6hc(!5LU86hhD
sQjs1Jh=d6mC_haG`sVlDpERSn[N-sb=%)2&$.E&_040b1?9ao`<k.\-Rs/G]A.C?c=rX1r7O
/qKofjU[H(Zf'5gc$cX`ecrc-2(5SDP\GKTo=o<cca-Lm[_0hGC@Vo1EXA:;OF9dp)gc^gea
TYF:D<j/lTKi:q((n6l3,\q?'^(SLk"QA"(L:^s>gR_jlO>c[6r6Q!;R.gSo<g*c')Ne25qM
>9?c.`q/'6oo*a`Tf4H]AOP\Yj5]A<BT8"OLRKnlKnD)FWhX^^2d5;Aj[%2`(=?KYqUk>3#!m;
2'DT'*WGF<GE#Yu=`%CD0ai`f_3]AVGiGHeM1:.J"*`N7cAV>=3l\6gY8CrlO4kEpPOAhfjeM
n1(_`TGe8pr.N.f5b31Cle34sT4;5l;:*W%Q]A;hoE=gAl*PN@_*I;(kg^]AehG24s5K`(+UoM
p+9ZH-m,E-RY*OU\]Ab^;FOt)DpD4CRghLQ)kdTTTNlupLY.d&gZg&Afi1,lUeUJ`Ccoa9Ehj
9kr$GVNAlNn#'%&scT_[1*U*Q-p.HYZ+O*RmO"aOFr..iAOE@he;";]A;c9DO<n(SoP_Md/JU
a2!muqNR!OH$a2[fY[l`esnkR6lhUX>Kg+A5?T9\9o+W(rNNg@(D,:VpiNK[1m9Z8Gh7s3&#
gsD8!c)&oA,#b3QZsL-EOPh$XL,EVsQsVA5'qgB9TffL2+;G=82:-9$7<bf=Ue2a-sfG6gUq
Ne?!uhGaH`#*MqN[!TPs)ZDU6VRArPaqpugFlh7O(d54$J*Yoe'M>j8%N`>+Z,0;gCdd7\mh
*F`n%^ISFD,DaUk0P`;5KG@4<]A6!<XEpBrr45uRn)XAd3&*ETHs=gCqNc?mF%_Tl+"Q=OC?D
,Vj/Te]AnpN=;e_`sBVHZO-K"/fW#ufO+0VGpMeLphHoYbm"MNnu1b38O@UG<([lT1(\cVO5Z
:Gupm9KhW$K;W>Q0j1W%U>?%Gm@^Y]Ah_PKo"Y,c-II"GCMO&>6bITkOZ:Yk@S+CT2b;Xe&l;
X.RDR.J1et7pg2#e4GKX*\,5M3/N6m]A4AGXLSm0*pgLSM?lOU*_<h+NIMF'9a^XbLshm+V"`
!XQM54eGRYA&$^b)N-!N^KFTgG,1JEe5NlL,U(MV9Ktc9$@K%K+j4m2,n'+1m"pOQ!i\@&TA
*`B@!sC*CqD^o`laZ\FSZkGLA?8<A/hA#%[I^48I*gTk0,7Ce=puC]AXPZjW8e=$B[;`3M6P:
]Aa"bF&P-%9G6F`Uc?#?Vo0'gc`Y1eH+[(aQ0C*W/@"KY<@^NE?ttaq@rq/hG@KRTRC/BmhE4
l%HGj.jIHWoP@f_:]AC@.ekO<D>KKm'C#iaJ]Abi-WVWp=Ppg_&WdM?R18Efe8=+$R[fDe!pW?
kIn!$ioS*LSa>MjF0)]At!\ImOn:M'q-U2nBUtiPBh3!q,;X:\+6P&7_duK)CIm[BmoZj1Ze5
+I`?\bQ./iQ2,"F"r4M,E7ODXI!:`Cs%kN9d("b3#3,=@I7_k<]A8UbZ3G/,ObUb-P&ZD$H60
FFR/$DT9^UG*%M0FFR/$DT9^UG*%M0FFR/$D[VMC/&McJJe:SCosK0Bm6583(\P/"L?pp#/+
u>"i7DVG5bj>5,$@?FcIg[6G4JO/ipZ=lhI!b!<~
]]></IM>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="0" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="267" height="23"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="2" y="359" width="267" height="23"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="chart0000_c"/>
<WidgetID widgetID="562f0b50-821f-4349-8d1e-77fd48d279b5"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="chart00" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<ExtendSharableAttrMark class="com.fr.base.iofile.attr.ExtendSharableAttrMark">
<ExtendSharableAttrMark shareId="427f32cd-a31c-41fa-903e-0057dcb0ecf2"/>
</ExtendSharableAttrMark>
<SharableAttrMark class="com.fr.base.iofile.attr.SharableAttrMark">
<SharableAttrMark isShared="true"/>
</SharableAttrMark>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ChartEditor">
<WidgetName name="chart0000_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="决策报表body样式的背景颜色设置为#00142E
图表样式&gt;提示&gt;文本的格式需要根据实际数据内容进行调整">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="15" bottom="15" right="15"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0"/>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="黑体" style="1" size="128">
<foreground>
<FineColor color="-11316397" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Position pos="2"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<ExtendSharableAttrMark class="com.fr.base.iofile.attr.ExtendSharableAttrMark">
<ExtendSharableAttrMark shareId="3b9858a7-bdcb-4799-9865-891ed60a4114"/>
</ExtendSharableAttrMark>
<SharableAttrMark class="com.fr.base.iofile.attr.SharableAttrMark">
<SharableAttrMark isShared="true"/>
</SharableAttrMark>
<LayoutAttr selectedIndex="0"/>
<ChangeAttr enable="false" changeType="button" timeInterval="5" showArrow="true">
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="PingFangSC-Regular" style="0" size="96">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<buttonColor>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</buttonColor>
<carouselColor>
<FineColor color="-8421505" hor="-1" ver="-1"/>
</carouselColor>
</ChangeAttr>
<Chart name="默认" chartClass="com.fr.plugin.chart.vanchart.VanChart">
<Chart class="com.fr.plugin.chart.vanchart.VanChart">
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-1" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<ChartAttr isJSDraw="true" isStyleGlobal="false"/>
<Title4VanChart>
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-6908266" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[基础面积图-项目情况]]></O>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="1" size="112">
<foreground>
<FineColor color="-919809" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="false" position="2"/>
</Title>
<Attr4VanChart useHtml="false" floating="false" x="0.0" y="0.0" limitSize="false" maxHeight="15.0"/>
</Title4VanChart>
<SwitchTitle>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[基础面积图-项目情况]]></O>
</SwitchTitle>
<Plot class="com.fr.plugin.chart.line.VanChartLinePlot">
<VanChartPlotVersion version="20170715"/>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-1" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isNullValueBreak="true" autoRefreshPerSecond="6" seriesDragEnable="false" plotStyle="0" combinedSize="50.0"/>
<newHotTooltipStyle>
<AttrContents>
<Attr showLine="false" position="1" isWhiteBackground="true" isShowMutiSeries="false" seriesLabel="${VALUE}"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
<PercentFormat>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.##%]]></Format>
</PercentFormat>
</AttrContents>
</newHotTooltipStyle>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name="">
<AttrList>
<Attr class="com.fr.plugin.chart.base.VanChartAttrLine">
<VanAttrLine>
<Attr lineType="solid" lineWidth="1.0" lineStyle="2" nullValueBreak="false"/>
</VanAttrLine>
</Attr>
<Attr class="com.fr.plugin.chart.base.VanChartAttrMarker">
<VanAttrMarker>
<Attr isCommon="true" anchorSize="22.0" markerType="AutoMarker" radius="3.5" width="30.0" height="30.0"/>
<Background name="NullBackground"/>
</VanAttrMarker>
</Attr>
<Attr class="com.fr.plugin.chart.base.AttrTooltip">
<AttrTooltip>
<Attr enable="false" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: left;&quot;&gt;&lt;img data-id=&quot;${CATEGORY}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${SERIES}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${CATEGORY}${SERIES}${VALUE}"/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0个]]></Format>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="true" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="1"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.5"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</Attr>
<Attr class="com.fr.plugin.chart.base.AttrLabel">
<AttrLabel>
<labelAttr enable="true"/>
<labelDetail class="com.fr.plugin.chart.base.AttrLabelDetail">
<AttrBorderWithShape>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="true" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
<shapeAttr isAutoColor="true" shapeType="RectangularMarker"/>
</AttrBorderWithShape>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
<Attr showLine="false" isHorizontal="true" autoAdjust="false" position="9" align="9" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="宋体" style="0" size="72">
<foreground>
<FineColor color="33023" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="宋体" style="0" size="72">
<foreground>
<FineColor color="33023" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: center;&quot;&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${VALUE}"/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="center" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.00%]]></Format>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.00%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
</labelDetail>
</AttrLabel>
</Attr>
</AttrList>
</ConditionAttr>
</DefaultAttr>
</ConditionCollection>
<Legend4VanChart>
<Legend>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-3355444" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr position="1" visible="true" themed="false"/>
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-2958103" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Legend>
<Attr4VanChart floating="false" x="0.0" y="0.0" layout="aligned" customSize="true" maxHeight="100.0" isHighlight="true"/>
</Legend4VanChart>
<DataSheet>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isVisible="false" themed="false"/>
<FRFont name="宋体" style="0" size="72"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
</DataSheet>
<DataProcessor class="com.fr.base.chart.chartdata.model.NormalDataModel"/>
<newPlotFillStyle>
<AttrFillStyle>
<AFStyle colorStyle="1"/>
<FillStyleName fillStyleName=""/>
<isCustomFillStyle isCustomFillStyle="true"/>
<PredefinedStyle themed="false"/>
<ColorList>
<OColor>
<colvalue>
<FineColor color="-16724866" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-25532" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-1418919" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-331445" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-16686527" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-9205567" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-7397856" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-406154" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-2712831" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-4737097" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-11460720" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-6696775" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-3685632" hor="-1" ver="-1"/>
</colvalue>
</OColor>
</ColorList>
</AttrFillStyle>
</newPlotFillStyle>
<VanChartPlotAttr isAxisRotation="false" categoryNum="1"/>
<GradientStyle>
<Attr gradientType="gradual">
<startColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</startColor>
<endColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</endColor>
</Attr>
</GradientStyle>
<VanChartRectanglePlotAttr vanChartPlotType="normal" isDefaultIntervalBackground="true"/>
<XAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="true"/>
<AxisLineStyle AxisStyle="1" MainGridStyle="1"/>
<newLineColor themed="false" mainGridPredefinedStyle="false">
<lineColor>
<FineColor color="-13219745" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="3"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-2958103" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="2" secTickLine="0" axisName="X轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="solid"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
</VanChartAxis>
</XAxisList>
<YAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartValueAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="false"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="false">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="2"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-2958103" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=10"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
</VanChartAxis>
</YAxisList>
<stackAndAxisCondition>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name=""/>
</DefaultAttr>
</ConditionCollection>
</stackAndAxisCondition>
</Plot>
<ChartDefinition>
<OneValueCDDefinition seriesName="季节性产品分类" valueName="毛利率" function="com.fr.data.util.function.SumFunction">
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<TableData class="com.fr.data.impl.NameTableData">
<Name>
<![CDATA[日维度渠道冰淇淋毛利率]]></Name>
</TableData>
<CategoryName value="渠道"/>
</OneValueCDDefinition>
</ChartDefinition>
</Chart>
<UUID uuid="883d2e8d-6c09-4193-bb13-7564e7e4dca1"/>
<tools hidden="true" sort="false" export="false" fullScreen="false"/>
<VanChartZoom>
<zoomAttr zoomVisible="false" zoomGesture="true" zoomResize="true" zoomType="xy" controlType="zoom" categoryNum="8" scaling="0.3"/>
<from>
<![CDATA[]]></from>
<to>
<![CDATA[]]></to>
</VanChartZoom>
<refreshMoreLabel>
<attr moreLabel="false" autoTooltip="true"/>
<AttrTooltip>
<Attr enable="true" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="" isAuto="true" initParamsContent=""/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="true"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="4"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-15395563" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</refreshMoreLabel>
<ThemeAttr>
<Attr darkTheme="false"/>
</ThemeAttr>
</Chart>
<ChartMobileAttrProvider zoomOut="0" zoomIn="2" allowFullScreen="true" functionalWhenUnactivated="false"/>
<MobileChartCollapsedStyle class="com.fr.form.ui.mobile.MobileChartCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
</MobileChartCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="257" height="137"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="687" y="210" width="257" height="137"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="chart0000"/>
<WidgetID widgetID="562f0b50-821f-4349-8d1e-77fd48d279b5"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="chart00" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<ExtendSharableAttrMark class="com.fr.base.iofile.attr.ExtendSharableAttrMark">
<ExtendSharableAttrMark shareId="427f32cd-a31c-41fa-903e-0057dcb0ecf2"/>
</ExtendSharableAttrMark>
<SharableAttrMark class="com.fr.base.iofile.attr.SharableAttrMark">
<SharableAttrMark isShared="true"/>
</SharableAttrMark>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ChartEditor">
<WidgetName name="chart0000"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="决策报表body样式的背景颜色设置为#00142E
图表样式&gt;提示&gt;文本的格式需要根据实际数据内容进行调整">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="15" bottom="15" right="15"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0"/>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="黑体" style="1" size="128">
<foreground>
<FineColor color="-11316397" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Position pos="2"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<ExtendSharableAttrMark class="com.fr.base.iofile.attr.ExtendSharableAttrMark">
<ExtendSharableAttrMark shareId="3b9858a7-bdcb-4799-9865-891ed60a4114"/>
</ExtendSharableAttrMark>
<SharableAttrMark class="com.fr.base.iofile.attr.SharableAttrMark">
<SharableAttrMark isShared="true"/>
</SharableAttrMark>
<LayoutAttr selectedIndex="0"/>
<ChangeAttr enable="false" changeType="button" timeInterval="5" showArrow="true">
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="PingFangSC-Regular" style="0" size="96">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<buttonColor>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</buttonColor>
<carouselColor>
<FineColor color="-8421505" hor="-1" ver="-1"/>
</carouselColor>
</ChangeAttr>
<Chart name="默认" chartClass="com.fr.plugin.chart.vanchart.VanChart">
<Chart class="com.fr.plugin.chart.vanchart.VanChart">
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-1" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<ChartAttr isJSDraw="true" isStyleGlobal="false"/>
<Title4VanChart>
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-6908266" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[基础面积图-项目情况]]></O>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="1" size="112">
<foreground>
<FineColor color="-919809" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="false" position="2"/>
</Title>
<Attr4VanChart useHtml="false" floating="false" x="0.0" y="0.0" limitSize="false" maxHeight="15.0"/>
</Title4VanChart>
<SwitchTitle>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[基础面积图-项目情况]]></O>
</SwitchTitle>
<Plot class="com.fr.plugin.chart.line.VanChartLinePlot">
<VanChartPlotVersion version="20170715"/>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-1" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isNullValueBreak="true" autoRefreshPerSecond="6" seriesDragEnable="false" plotStyle="0" combinedSize="50.0"/>
<newHotTooltipStyle>
<AttrContents>
<Attr showLine="false" position="1" isWhiteBackground="true" isShowMutiSeries="false" seriesLabel="${VALUE}"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
<PercentFormat>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.##%]]></Format>
</PercentFormat>
</AttrContents>
</newHotTooltipStyle>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name="">
<AttrList>
<Attr class="com.fr.plugin.chart.base.AttrTooltip">
<AttrTooltip>
<Attr enable="false" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: left;&quot;&gt;&lt;img data-id=&quot;${CATEGORY}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${SERIES}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${CATEGORY}${SERIES}${VALUE}"/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0个]]></Format>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="true" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="1"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.5"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</Attr>
<Attr class="com.fr.plugin.chart.base.VanChartAttrLine">
<VanAttrLine>
<Attr lineType="solid" lineWidth="1.0" lineStyle="2" nullValueBreak="false"/>
</VanAttrLine>
</Attr>
<Attr class="com.fr.plugin.chart.base.VanChartAttrMarker">
<VanAttrMarker>
<Attr isCommon="true" anchorSize="22.0" markerType="AutoMarker" radius="3.5" width="30.0" height="30.0"/>
<Background name="NullBackground"/>
</VanAttrMarker>
</Attr>
<Attr class="com.fr.plugin.chart.base.AttrLabel">
<AttrLabel>
<labelAttr enable="true"/>
<labelDetail class="com.fr.plugin.chart.base.AttrLabelDetail">
<AttrBorderWithShape>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="true" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
<shapeAttr isAutoColor="true" shapeType="RectangularMarker"/>
</AttrBorderWithShape>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
<Attr showLine="false" isHorizontal="true" autoAdjust="false" position="9" align="9" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="宋体" style="0" size="72">
<foreground>
<FineColor color="33023" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="宋体" style="0" size="72">
<foreground>
<FineColor color="33023" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: center;&quot;&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${VALUE}"/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="center" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.00%]]></Format>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.00%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
</labelDetail>
</AttrLabel>
</Attr>
</AttrList>
</ConditionAttr>
</DefaultAttr>
</ConditionCollection>
<Legend4VanChart>
<Legend>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-3355444" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr position="1" visible="true" themed="false"/>
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-2958103" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Legend>
<Attr4VanChart floating="false" x="0.0" y="0.0" layout="aligned" customSize="true" maxHeight="100.0" isHighlight="true"/>
</Legend4VanChart>
<DataSheet>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isVisible="false" themed="false"/>
<FRFont name="宋体" style="0" size="72"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
</DataSheet>
<DataProcessor class="com.fr.base.chart.chartdata.model.NormalDataModel"/>
<newPlotFillStyle>
<AttrFillStyle>
<AFStyle colorStyle="1"/>
<FillStyleName fillStyleName=""/>
<isCustomFillStyle isCustomFillStyle="true"/>
<PredefinedStyle themed="false"/>
<ColorList>
<OColor>
<colvalue>
<FineColor color="-25532" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-1418919" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-331445" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-16686527" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-9205567" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-7397856" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-406154" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-2712831" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-4737097" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-11460720" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-6696775" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-3685632" hor="-1" ver="-1"/>
</colvalue>
</OColor>
</ColorList>
</AttrFillStyle>
</newPlotFillStyle>
<VanChartPlotAttr isAxisRotation="false" categoryNum="1"/>
<GradientStyle>
<Attr gradientType="gradual">
<startColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</startColor>
<endColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</endColor>
</Attr>
</GradientStyle>
<VanChartRectanglePlotAttr vanChartPlotType="normal" isDefaultIntervalBackground="true"/>
<XAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="true"/>
<AxisLineStyle AxisStyle="1" MainGridStyle="1"/>
<newLineColor themed="false" mainGridPredefinedStyle="false">
<lineColor>
<FineColor color="-13219745" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="3"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-2958103" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="2" secTickLine="0" axisName="X轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="solid"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
</VanChartAxis>
</XAxisList>
<YAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartValueAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="false"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="false">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="2"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-2958103" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=10"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
</VanChartAxis>
</YAxisList>
<stackAndAxisCondition>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name=""/>
</DefaultAttr>
</ConditionCollection>
</stackAndAxisCondition>
</Plot>
<ChartDefinition>
<OneValueCDDefinition seriesName="季节性产品分类" valueName="毛利率" function="com.fr.data.util.function.MaxFunction">
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<TableData class="com.fr.data.impl.NameTableData">
<Name>
<![CDATA[日维度渠道冰粽毛利率]]></Name>
</TableData>
<CategoryName value="渠道"/>
</OneValueCDDefinition>
</ChartDefinition>
</Chart>
<UUID uuid="099f699e-e598-4b09-a2ed-042ce4df4f9e"/>
<tools hidden="true" sort="false" export="false" fullScreen="false"/>
<VanChartZoom>
<zoomAttr zoomVisible="false" zoomGesture="true" zoomResize="true" zoomType="xy" controlType="zoom" categoryNum="8" scaling="0.3"/>
<from>
<![CDATA[]]></from>
<to>
<![CDATA[]]></to>
</VanChartZoom>
<refreshMoreLabel>
<attr moreLabel="false" autoTooltip="true"/>
<AttrTooltip>
<Attr enable="true" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="" isAuto="true" initParamsContent=""/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="true"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="4"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-15395563" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</refreshMoreLabel>
<ThemeAttr>
<Attr darkTheme="false"/>
</ThemeAttr>
</Chart>
<ChartMobileAttrProvider zoomOut="0" zoomIn="2" allowFullScreen="true" functionalWhenUnactivated="false"/>
<MobileChartCollapsedStyle class="com.fr.form.ui.mobile.MobileChartCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
</MobileChartCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="257" height="131"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="695" y="78" width="257" height="131"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="report4_c_c_c_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report4" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report4_c_c_c_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="1" left="1" bottom="1" right="1"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__54747B55D03CBA03B526498E03A03464">
<IM>
<![CDATA[lO<9(kN.ld@UNU%p%320@UNS-%`Gt=fRP082QODE0Slk%FE%_gR.L%J`_9u7&_B:u;caoN(\
-W&+$LXt,W.<hdBSo"Y`<_>q<$T;s)7=b3A]AI,Z?K=A2XWYBs5s@aBh`'Zqm1S"0:Q2<PlnS
K'`.fIgqM`#'*CThq'-1gBiE*j^u-om!Z7X=r\D\+$kq.f(`=/c#Qk0tiCRZ;OSj4=&4fibW
-kIr?/Jr%hf%5"MDd!lf?`3!qs0T\@(H(I(d"aF<;EK`;<=Rq8!T,b+&tM)HrTp?nknMDb"%
_X.N_YSWdIeAW:IctI#jajr;6KVVj[>5)&Ntpld&c$NqK"TdeuFu<Yk/2OF()LLQ@#FJ<\ft
HZ.&CCRZDI!&Z%k5.WJQUTunPl592]AcPnJc:MU$CPeki!cXiYG65'>~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[723900,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0" s="0">
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style style_name="默认" full="true" border_source="-1" imageLayout="1">
<FRFont name="simhei" style="0" size="72"/>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[lO<9(kN.ld@UNU%p%320@UNSDARJmUj^81JoJ+[XARLVpm-3LH;DI@ZNJ!YC%K\2AQN*:FR@
,;KnBH4$JT]A5Pj>ZP2Z^H;Lr;GM9qERa`$',gFm7ioP0lI>snpb-P1)b6:5:$_-TsaVP:0,]A
M'*=$i;=4+]A#;I'E`4L8GBE_Bh-4m9s#Zfm23=/)6GYMTId6W[i5h#o[<No>!1cReV-)4X6[
>nuBeN0^Q<9pL6;6?Ts8%"@l*S!3NF]A@\*ekrQE>">u\C)thcWg1k5CUPV"K=O_Vp4$lF4M]A
&Mi<e)*TF*Do.R\D]A&D2q=acS(kqS_BT`r8a!`?7HB=$N$o:'jVp~
]]></IM>
<ReportFitAttr fitStateInPC="3" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="1" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="273" height="285"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="679" y="67" width="273" height="285"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<Listener event="afterinit">
<JavaScript class="com.fr.js.JavaScriptImpl">
<Parameters/>
<Content>
<![CDATA[setTimeout(function(){
	$("div[widgetname=REPORT3_C_C]A").find(".reportContent")[0]A.style.overflow="hidden"
},100);]]></Content>
</JavaScript>
</Listener>
<WidgetName name="report3_c_c_c_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report3_c_c" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report3_c_c_c_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="1" left="1" bottom="1" right="1"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__9BB2985780BA65AD1EEF95B35E198624">
<IM>
<![CDATA[>uh82;Y_49[sY/7bUZq=@@3Qs8oi-LV(>=md7MS^PXTAnS8cRr9UuE+)&5l/=h[R7^`!?pnq
i0:b?2pNUn`L.>DnjPi_,Lk$6/0AbY.,HkFR&#kI]AX?q^n/Pl&_RoAh0ubJj:G7[(gN-#R$G
FhIDP)(9^60*;i)F'-FTbG?@>&E\t*Wr/aokM@/1Q)>VXV5?7?@CRY:_9kYZtV62@DA@-oVn
GRWr1O07LG>t_:cTeT\?R"$)(`KQe",<tI5s,8.2g0Vm&nlQ/"ObNNZk"td@nJ<6_`[C:7<7
kLIj[#qE>?Am=Y*U_]AF0GA=<L2r.4c.@%[i1_1VqBMllF16kJAAK*eWdfE?033,X9D.Bq*<Z
r,bYAlfurr/EL:nN.jI6+6D"nc(k\U5[UTLSlh4'ES]ABhN8BqUDL55aftgDA=bp_hH>DLcO]A
"jFfduJC&Zh_tcsY.ENh9raC&#DkA*LMY=j>7_orPP/22?HXT"K>HG`qZ`S3i+tCQmM8">,2
"2:E]AMm]Aa3]AR+qq5Y`1VMcKuC^dFtBm2qVdi%jS35Qak1pdYjW_]AeQ;a3GTk:Uh5QadLrGVT
uC@Z1)c`;^U>l@@P+@(J\/^$W9[#bE-q;u=YR!29V_;q_mOsI-q;`RjKTKM*l^!8'Vd]A;fbS
Y1<l7a9Or@2'UhWVK+&nh*qR<=%'kYXb4@cY`G`d$$@[+XA%Y)N:P=-(:q7HNfL_r<MF))&`
A>f;8"XS2Yp>WSQa`0%oR)Y3P]A1+n2h*ptpkA"2)0m/jQ*d2a5h6#C^d.m;2i_K]Ae@+KH_[9
l?]AM"NP"J&t`;6`:MRd>Y&+DR?,S-;fh$O51V2<,SCjDW>(f:^9XI]AJP#k3lZi-gASN44,n6
5EATFt>dL;Q.[]ABs]AC7prlR8`3+^UXTr;J=J6*XI:)SL+1I>h.&(p&16o0%=6-["RV/l9Pfe
@p7GDQFV$nTCK=b%iA$UF,["VC$RP"R91F.2DMI0O]AYHnq6)3![M(0C%:Z+d15^Tj,Ze?MdE
;2?YZV#c)&nQS&091p(!]AagAY`/HFd!4e>I2b[`&d7Ce@@51.RFDiRJNZ_PY>Elc%pnIR3mJ
ohj\6Zpa`:]Ao,+TpIKMubQs8n'DF;'2nUZ#-VLem0r-i6[SskC3]A(6pgYa=s8?KKdk>riI81
&]A8;<Z*bpYB81Z2HP\l!UQQjcXC8VIsX8'qBL%ZD;$4=-#qjI38I0\b6OH_YtNRdDm`CQ+ca
kbXn6&,&BH]A#d1r,@ndk(Opf9:<Uk<'U/0U+]AHMt5L1f8Up*#eTj3?^45_g^phN2'.hU:`dW
BkX6?@gNfa6$DKP7(\\:T(Z05Y0,BFOT?^*aSrUs4fn^N7Zc("DhnIqLY3h8_/Ta6,XanNq^
A-O4XL^kE!PJAHdN/Q2h,DO.JKLmW?DsV%j".?1`8:pR308LReIJH@M-\MJ0I%N6L&-8K:KF
dpGj[.i`3K4E>=n2%V%Ua`m65I`Fgr*s%$IHRCg_O/R1UU7?["d,9TZlOJIC:tYl:1IUW)CD
9Kf0B9.p+E4&V;U_V0N:)uE!1.@[dZ->M4q]A?rFnBmFF-<3L<ZgN0d]ASc!QtNa2/CEk@6A&4
%c$)HH]AYPXa,1oi2<GNW.C[L<T1eRl#'=dp(ADRp9kLqH%bO;SIBb!*[SXMRTSCYfA>nUL)^
Kt!bel+YJS=5;1=T\:Z9ZK0U[8sU;T<TrJ@%[JST)4>(filO!UZJ1-E1AibDi1:i3a5%q`@Z
Sj9a7>;,(85(EgQ8gH@(=ipZ4tC5QDU9klY,)kP]ArNpd?Mm^XeqI@.SQHi=\_pLM5FXK25:G
U450B_q08=bWb@sEQ]A+Y'Q+--Cqf-l?B;grndZHqQ0+[eg,6(2I=dUB3#9!0K"9l[J=%-oCa
aomADT5;B0/LC1[1&LfrI(4JltH3Gs#%A!Kb"<$hEQq/sQU%QU3?%RF:#F29Q&0N)JKFoL0^
4-`mBKXbcg3\B-^QYio`8.7Pu@I8pCT#/GHo2jlX!K0(qI3rkd.>i[7P.I+:iSOhRB&Q&C#G
@1XI2r"C82?P*#eiOnM3lB1l3J)B"_S"&&0..BN,m$;6*HBh"-i!qG@uD4#Zs!sc#!EKdZAD
6/`1JJ\[&@B*.A.4<@0<"/1m.hE]AmX_Is*e`-L5Q&BG7cu,R)>JbX:o_\D=#>GT#Os#?4&73
+LCDj$UELchmL7<0&Non0$5<#"6_fL?]Ah!7lE6rd!^_rTPWOI$mr_r[SnBNGY2$PUc0+LP)Q
Ta&jgnTHS5'Meg'#W26\sP!W9gXY`>Y;TS*.DGRDlaAVe4/$Qda[0/d*.U^o8*jejF:`oo8a
qfWmsY56RDPi&J8lY,ZT,Le/g:U=7$e;Fbl4JugS+N&!'XNf-W^:%9gR4^!>_db8H=ESU'Vh
!b.n&F+&Xno1S3qFm4EKnGg3T4_He+cHoq[IF+%4T$>\T\)\^`"i/B5ZWDJbq9K"I=`<@#Q6
NoOP;3raeA"c=oP"TF#hh#f$CHY-e[t*1VS5T9e'tqNF&.c43en5,g%?:Rt%.G_t55t8^&S=
.Di3!%4s"sb#O8nEbc:p&Kp=dG'o+g$R(EUjI7DSF_D)Z*,SP_a14bM)&3sh-bK&=CFIeYoM
/65a5#SI1tss)Eu:!&b5U#[2sg.CGHO4+PT4g0a$/E)=DV;1WLVFMfg?g4s"r&tY\3R2f_>#
js"MJj.TQ?B:mQ%9,'+8%I3q/YFXgfleQuVomg%`-#MEZ(B%W!O[^'#.pZoN-5p2Q2R#,W5!
eHHJ:h="J=;9fpBViQ)^M4>60?BKhF+<%R~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[822960,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[365760,3444240,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0">
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="1" r="0" s="0">
<O t="XMLable" class="com.fr.base.Formula">
<Attributes>
<![CDATA[=FORMAT(DATEDELTA(TODAY(),-1),"M月d日") + "销售贡献榜"]]></Attributes>
</O>
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style imageLayout="1">
<FRFont name="SimSun" style="0" size="120">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[mF1r:;froWn>R-,!bi8i\+FZlp:qkOOD?."#71DL=#h07+kOg\j"^h"\#BlS,E1<C"Bo?W7L
0FT@*4]AY#qVQ^fO4;-g/Q^aaY(GR@\]Ajt(OVhGds8^k4eM3)ID=tCV_M;#gJ,+)'ZqK+0/=T
&H52E+XZ<ob[H0>)CT&:&PWOPVr89h[j4nbEP9N0TQDVTSl8mudZ#tJmo=Z_h6?MfVp$fEfd
%`07H]A%:&@Hs>1H&gSTI;m:a7ke45MWt7%fODS%h-O(H>=XtldY&SrX2sYKm,PmUDVk%gGVN
;q(dBb#=I`b7dL1hYR8`S593q"Y>2B;FE%2;m=hCg8`98hs:_ZhM3_%6"KKV/aP4/=&Q7s[3
DLQ4&IFW?t=k%Ikh?$8[S!F;E2SjC()@@bLUAl7[5:f_LnC<NRWk]A@m9(5)UBK@8ad,-qj?0
0ME?:$W![Sgl:_XL*E"WHd*rM?ue5OUf^i_<,_&Im`nE(7e+?u]ANYY9qU^W4ZiEfO^UG?.%G
s0L(fPS^qR_q@,3#CX5'(=.+O)H80hL9*Xc`?@s8k7YYcGZeiL-V!j]Aio]A26rZ9r[h?oPnQ7
[sTW6=d6pF[@Qc1!>XPk*;jfDs3\KnBtc;J^dU8NYMPCm]A$A!el"?iIKl2L\qk`dN6VOOVR@
QDC+;n+K0&b<X3U3YI%p8_$DIE9;GoGeB"68p8H.sc)59MS=eRQaNHo14*niuJJ^DSg)pg*h
dsFT1G3.3n$J$XRMbWJ$cM21O4Kji.RW/k7fHgO1_c*DqB<n'*)KbIR=8u:u@$rpg:#m,\GS
0->(WI^?f-$I7B=U!emJ)ZoW%3:b&o`\M0fD#uI\*t:P<L!$iH#F:LFI)B'==r1B#X59h<]AZ
K9PHAbV@^\BnOPDMBm=1\P0`I;PMGF0\_puaXQG3b>s3]A%0Pe0m\io%!d5TeDF%f*J,8]Ab&J
g=MR/&P]A6!!]Adb+gE$t_t)^GS,G2b=q).&o+"<-fkS2YoVst;I2Slu_(dr!K&\'LZ>isBnt-
)["2RirQ/-e75Ukl:SHn*SrW#45rW%5rV"'Jl;sReqSAlVNU"1OdjYWAt;?e2,(7Os@k!ju&
+?UcUMhrK5So7r:L(a:-r7)557c)ppSK+MlbDnblC7+Raegi$8=P=\:JHS7T5UK9C?qWe'K!
Tu_Bf1p(K4Wc>I^aTGfJ'q]An5TAR_W7(U%WWDL8HNTHO]A8:Z>rk>Y<+XX.cNsBN=kNE29^o/
mio_bd79pk#V^Q'pnT+[t%rB\"+b6VEcJ'oPbH'A^b1tl$kp8OLbfI_9WSIFOFWB_#DFiMF(
#1E*4]A#`'P+=`CfZ]A^@$&p>PU)<@e,/gppcj`%]AOlDcPj4)A]AZ3YbgOg;$0'sEZlHRE]A`V)G
l@OX#%O'??fk_k^2LafGYs_U/Ai^S?pF\5`YC#q9;SK)r9D"W`lpfFF8*/f!35<H-a5JY7bO
FW?ju[(:6\!h\>=%ZAE]A%O&VP%9"=`Nb%Va)DZ-/RT.=nDQ1b)37OS^j@\V:qXNoc68#<<pj
sfj:aP:'-$7V.&<9!4)3>)\G5%qQE/nLs%[&9=N!cM&A%?"=n:`ph^HMWfiaUW<?u;uh9Htj
EV<HT:*UsQpBLs!+T]A$u=>9[$[a#WJ[mmgOXO,@;teA[]Aa<RtBX-gFk\cLQ3!*OXVlghs5!C
>X;i+r$^V74:J7MGSsM'VPe$-peN':kU#,Ta6(gW.>LX[*M@9^tA^!D<#[3=hI`\iN.)@7^&
n4Ba#_Q,l)I+SQL.J-:h/,,F/r0UR4UKLPJ\)%0~
]]></IM>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="0" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="267" height="20"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="245" y="148" width="267" height="20"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="chart01"/>
<WidgetID widgetID="015be30b-a786-4416-906f-f22d74aad54f"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="chart0" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<ExtendSharableAttrMark class="com.fr.base.iofile.attr.ExtendSharableAttrMark">
<ExtendSharableAttrMark shareId="a467586c-2f7e-4f67-934e-3448cac49e03"/>
</ExtendSharableAttrMark>
<SharableAttrMark class="com.fr.base.iofile.attr.SharableAttrMark">
<SharableAttrMark isShared="true"/>
</SharableAttrMark>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ChartEditor">
<WidgetName name="chart01"/>
<WidgetID widgetID="b2758efb-a20d-43fe-84a0-89b5b43add7d"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="【使用该组件前，请先安装模板组件复用插件 https://market.fanruan.com/plugin/0a49e40f-99da-48c7-950e-54a24e853204】
1.决策报表body样式的背景颜色为#080722。
2.设置标签&gt;自定义，将系列值的和显示在条形图外侧。可参考自定义标签-https://help.fanruan.com/finereport/doc-view-1882.html?source=4#3示例三
3.点击右上角可排序">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="15" bottom="15" right="15"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0"/>
<WidgetTitle>
<O>
<![CDATA[▍华东地区销量统计]]></O>
<FRFont name="黑体" style="1" size="128">
<foreground>
<FineColor color="-11316397" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Position pos="2"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LayoutAttr selectedIndex="0"/>
<ChangeAttr enable="false" changeType="button" timeInterval="5" showArrow="true">
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="PingFangSC-Regular" style="0" size="96">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<buttonColor>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</buttonColor>
<carouselColor>
<FineColor color="-8421505" hor="-1" ver="-1"/>
</carouselColor>
</ChangeAttr>
<Chart name="默认" chartClass="com.fr.plugin.chart.vanchart.VanChart">
<Chart class="com.fr.plugin.chart.vanchart.VanChart">
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="true">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-1118482" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<ChartAttr isJSDraw="true" isStyleGlobal="false"/>
<Title4VanChart>
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="9"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-6908266" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[▍华东地区销量统计]]></O>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="1" size="96">
<foreground>
<FineColor color="-919809" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="false" position="2"/>
</Title>
<Attr4VanChart useHtml="false" floating="false" x="0.0" y="0.0" limitSize="true" maxHeight="15.0"/>
</Title4VanChart>
<SwitchTitle>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[▍华东地区销量统计]]></O>
</SwitchTitle>
<Plot class="com.fr.plugin.chart.column.VanChartColumnPlot">
<VanChartPlotVersion version="20170715"/>
<GI>
<AttrBackground>
<Background name="ColorBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-14701083" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isNullValueBreak="true" autoRefreshPerSecond="6" seriesDragEnable="false" plotStyle="0" combinedSize="50.0"/>
<newHotTooltipStyle>
<AttrContents>
<Attr showLine="false" position="1" isWhiteBackground="true" isShowMutiSeries="false" seriesLabel="${VALUE}"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
<PercentFormat>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.##%]]></Format>
</PercentFormat>
</AttrContents>
</newHotTooltipStyle>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name="">
<AttrList>
<Attr class="com.fr.chart.base.AttrBorder">
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="4"/>
<newColor autoColor="true" themed="false">
<borderColor>
<FineColor color="-1" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
</Attr>
<Attr class="com.fr.chart.base.AttrAlpha">
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</Attr>
<Attr class="com.fr.plugin.chart.base.AttrLabel">
<AttrLabel>
<labelAttr enable="true"/>
<labelDetail class="com.fr.plugin.chart.base.AttrLabelDetail">
<AttrBorderWithShape>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="true" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
<shapeAttr isAutoColor="true" shapeType="RectangularMarker"/>
</AttrBorderWithShape>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
<Attr showLine="false" isHorizontal="true" autoAdjust="false" position="6" align="9" isCustom="true"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-1775376" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-1775376" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: center;&quot;&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${VALUE}"/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="false" isCustom="true" isRichText="false" richTextAlign="center" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="function(){ return this.value + &quot;万&quot;;}" useHtml="true" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
</labelDetail>
</AttrLabel>
</Attr>
<Attr class="com.fr.plugin.chart.base.AttrTooltip">
<AttrTooltip>
<Attr enable="true" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="1" size="64">
<foreground>
<FineColor color="-6312513" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="1" size="64">
<foreground>
<FineColor color="-6312513" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: left;&quot;&gt;&lt;img data-id=&quot;${CATEGORY}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${SERIES}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${CATEGORY}${SERIES}${VALUE}"/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#,##0.00]]></Format>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="function(){
var points = this.points ;
var total = &quot;&lt;div align=center style=&apos;width:100%;height:100%;&apos;&gt;&quot;;
total += &quot;&lt;div align=left style=&apos;width:125px;height:85px;background-color:#0F2E66;&apos;&gt;&quot;;
total = &quot;&lt;div align=left style=&apos;height:20px;line-height:22px;font-size:10px;color:#32C5FF;padding-left:5px;&apos;&gt;&quot;+points[0].seriesName&quot;&lt;/div&gt;&quot;;
total += &quot;&lt;hr style=&apos;margin-left:5px;height:1px;width:110px;border:none;border-top:2px solid #32C5FF;&apos; /&gt;&quot;;
var val = points[0].value;
var vals = val.split(&quot; &quot;);
for(var i=0;i&lt;vals.length;i++){
if(vals[i].trim().length&gt;0)

{ total += &quot;&lt;div align=left style=&apos;height:25px;line-height:20px;font-size:14px;color:white;padding-left:5px;&apos;&gt;&quot;+vals[i]+&quot;&lt;/div&gt;&quot;; }
}
total += &quot;&lt;/div&gt;&quot;;
total += &quot;&lt;div align=left style=&apos;margin-top:5px;margin-left:25px;width:60px;height:80px;background:url(/webroot/staticfile/point_gis1.png) no-repeat 0px center;&apos;&gt;&lt;/div&gt;&quot;;
total += &quot;&lt;/div&gt;&quot;;
return total;
}" useHtml="true" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="true" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.5"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</Attr>
</AttrList>
</ConditionAttr>
</DefaultAttr>
</ConditionCollection>
<Legend4VanChart>
<Legend>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-3355444" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr position="4" visible="false" themed="false"/>
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-6312513" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Legend>
<Attr4VanChart floating="false" x="0.0" y="0.0" layout="aligned" customSize="false" maxHeight="30.0" isHighlight="true"/>
</Legend4VanChart>
<DataSheet>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isVisible="false" themed="false"/>
<FRFont name="宋体" style="0" size="72"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
</DataSheet>
<DataProcessor class="com.fr.base.chart.chartdata.model.NormalDataModel"/>
<newPlotFillStyle>
<AttrFillStyle>
<AFStyle colorStyle="1"/>
<FillStyleName fillStyleName=""/>
<isCustomFillStyle isCustomFillStyle="true"/>
<PredefinedStyle themed="false"/>
<ColorList>
<OColor>
<colvalue>
<FineColor color="-14388055" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-10055191" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-8725560" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-7839293" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-20792" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-7115679" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-1780908" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-14837358" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-6501274" hor="-1" ver="-1"/>
</colvalue>
</OColor>
</ColorList>
</AttrFillStyle>
</newPlotFillStyle>
<VanChartPlotAttr isAxisRotation="false" categoryNum="1"/>
<GradientStyle>
<Attr gradientType="gradual">
<startColor>
<FineColor color="-12525871" hor="-1" ver="-1"/>
</startColor>
<endColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</endColor>
</Attr>
</GradientStyle>
<VanChartRectanglePlotAttr vanChartPlotType="normal" isDefaultIntervalBackground="true"/>
<XAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="true"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="false">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="3"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="64">
<foreground>
<FineColor color="-6312513" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="X轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
</VanChartAxis>
</XAxisList>
<YAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartValueAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="false"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="false">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="2"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="64">
<foreground>
<FineColor color="-6312513" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=1" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=10"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
</VanChartAxis>
</YAxisList>
<stackAndAxisCondition>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name=""/>
</DefaultAttr>
</ConditionCollection>
</stackAndAxisCondition>
<VanChartColumnPlotAttr seriesOverlapPercent="20.0" categoryIntervalPercent="20.0" fixedWidth="true" columnWidth="7" filledWithImage="false" isBar="false"/>
</Plot>
<ChartDefinition>
<OneValueCDDefinition seriesName="类型" valueName="金额" function="com.fr.data.util.function.SumFunction">
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<TableData class="com.fr.data.impl.NameTableData">
<Name>
<![CDATA[日维度贡献榜]]></Name>
</TableData>
<CategoryName value="渠道"/>
</OneValueCDDefinition>
</ChartDefinition>
</Chart>
<UUID uuid="bca41bca-aa69-4e12-905f-1b04c480f65e"/>
<tools hidden="false" sort="true" export="false" fullScreen="false"/>
<VanChartZoom>
<zoomAttr zoomVisible="false" zoomGesture="true" zoomResize="true" zoomType="xy" controlType="zoom" categoryNum="8" scaling="0.3"/>
<from>
<![CDATA[]]></from>
<to>
<![CDATA[]]></to>
</VanChartZoom>
<refreshMoreLabel>
<attr moreLabel="false" autoTooltip="true"/>
<AttrTooltip>
<Attr enable="true" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="" isAuto="true" initParamsContent=""/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="true"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="4"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-15395563" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</refreshMoreLabel>
<ThemeAttr>
<Attr darkTheme="false"/>
</ThemeAttr>
</Chart>
<ChartMobileAttrProvider zoomOut="0" zoomIn="2" allowFullScreen="true" functionalWhenUnactivated="false"/>
<MobileChartCollapsedStyle class="com.fr.form.ui.mobile.MobileChartCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
</MobileChartCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="383" height="187"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="245" y="172" width="383" height="187"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="report100"/>
<WidgetID widgetID="61730c8a-7c6c-4cd9-8d29-8699cc6b57d0"/>
<WidgetAttr aspectRatioLocked="true" aspectRatioBackup="6.551724137931035" description="">
<MobileBookMark useBookMark="false" bookMarkName="report1" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<ExtendSharableAttrMark class="com.fr.base.iofile.attr.ExtendSharableAttrMark">
<ExtendSharableAttrMark shareId="36e9078c-ee36-4c4d-a00b-bf26f2320f87"/>
</ExtendSharableAttrMark>
<SharableAttrMark class="com.fr.base.iofile.attr.SharableAttrMark">
<SharableAttrMark isShared="true"/>
</SharableAttrMark>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report100"/>
<WidgetID widgetID="40ac03ef-343a-4fbf-b91e-f18c23abd29c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="1.body背景颜色设置为#021C23；">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<FileAttrErrorMarker-Refresh class="com.fr.base.io.FileAttrErrorMarker" plugin-version="1.5.4" oriClass="com.fr.plugin.reportRefresh.ReportExtraRefreshAttr" pluginID="com.fr.plugin.reportRefresh.v11">
<Refresh customClass="false" interval="0.0" state="0" refreshArea=""/>
</FileAttrErrorMarker-Refresh>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[1714500,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[3810000,2438400,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0" s="0">
<O t="XMLable" class="com.fr.base.Formula">
<Attributes>
<![CDATA[=today()]]></Attributes>
</O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="1" r="0" s="0">
<O t="XMLable" class="com.fr.base.Formula">
<Attributes>
<![CDATA[=CONCATENATE("星期",switch(weekday(),"0","日","1","一","2","二","3","三","4","四","5","五","6","六"))]]></Attributes>
</O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="2" r="0" s="0">
<O t="XMLable" class="com.fr.base.Formula">
<Attributes>
<![CDATA[=format(now(),"HH:mm")]]></Attributes>
</O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style horizontal_alignment="2" imageLayout="1">
<FRFont name="微软雅黑" style="0" size="80">
<foreground>
<FineColor color="-1578771" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[m?q`lP%biTWMX[5c(%Oqjb_ZJd3^qL#;l[R7`WqHedfQoL;fskjs`/F5b*!u4,JrcjU%g>eZ
?P0;p#Yd)(!l:9jW^7JqUr_+p`4P_n1HDVtmRo@J@A,"/"H9If@[^H10pFmcV<fl[>u90e1t
$KuXN3#ip<mE9K"fBK61u>'BI\+502?bA+^V+Rm71cnA/Tf?I"-^=k4<U.BCH,I_B:9m]A93C
?g(XjThJ0%j,VZgq"p]A!]A#LfNk!j>ES%Yb!n?eFcFKFrpUb?NZRuY*]Am5$If88]A=NBX7(o/e
]A%Uo%Ji/83V,ePfCBocIeR!hFT<_DuM7kfe!Q9q)9I7&HSO*0/2^r&T@k5e]ANL0=A@^_C/d&
3go)jLK2.tD0?NP@u.kfN>*TN]A@]Ag,dc_(os-cJ9k"jjqpl)nu%h,A'D8W#-FD)2lFl%pX0J
'Js<<k%ppI(1fra#f;=U?2'7'S?RJD*/g;uXD.s/A!RWaRB:UP'dNX@0te9MGVJQ8F"s._`Y
<mr0a3ZTVJD*725"L.A:7<2602p;>llBj,c?A[bWAFSbkD?>dGW0&>SYC@F%E7)c!+:W[Nel
lhZ:5<?M;K9^7d'+M-6:hICeorHk(E3ithCbaP$m`K!TNj*\>RM]A9g/ft;8nV.F6Y/"A0J9f
GY.=h_"=("7pnp0tF'Lt&J_"kal8hQ-a.7_&%Pu3qE&*KROYWS?:%)jDK]A-RP,EA&Y`m6FT*
g8ncPBQ]A*o(-ArA\3maLX/*!I996+/W85`_kGaEtT+S/2MaKq!?&/X$mCBHu:<oa>fnT2uD8
8c:P@g):K(ffES=&nkmh]ARbiq)(X"%0=F7fLbY-^fbHK1e/%s(l,Tp_a#c4c9/lBs>1!nV6p
sg$6?U(c03?'FC&NJ_ugMGaDB'k)W*C+lshf20Kb=U=%3%T`ZcV%X(+#D3YOdi=81s;u\[hO
L#/p4%_E`h#U*^ch;l[PM;$beX5]A/E@b.ajcRaPnLQ+1Oo>VP:B6%sppPAn3g6clSZn#`m2$
q@ZGs)_5:@!omcc1Z2/A,iq!;f9P@BZ=iZ")6j1el=A(S`Ao1dE\V<k&rH%N<)Y$[WEXlFS1
$4NUGnVr=acK>RjFhLX0/E!dKdiNl"5m)IsZ;!CFQ$r2g$bEnckgX#dJeU^-oMrMLb(WX!hX
l8;p#um,R'@uOD\O)74=,B5=*JQ\Z1B0Zd\^a9%"DF.L4KYEVgq6.="HRdf>O#kBf.JK'>),
mb#Yf#?/X>t9`RDO"G(*tS:lG:Ua$V:U_$^"WrGi2eB_q'V=,T]AQ7?p&;RStQ/d*j^*RWn?M
Ym79$l^GS2`IQBI[P(J1c,[o"@.LDL9=FWfrF&:ji'>@_R#44,UHpkUe36(n6VZ3l%f7\5sT
IjBc^K@0o?$GU+aFS(Uu[AN<YTOY&69>ptYdnM6\p1gEi);D#=jXgP]AVd@M+ZUh,]AQpPWs1Z
N)VNlOHV>o>!e;&"8$<UH:S@QSpI.IoC`K,i[aWlLKYudMLGb\Gf*4p!%f6mPpi0@+S]ASo;^
YV9K^ZhERYRbs1`W-4-!/8d4J4*_Y;<lU?>t1>Og$M]AS70\Hkn7'Zrrs9Tk'<r-]A`B#6KRli
g0Zuf*H@R8r"GQHDVApeeQMLe52dbk6\A2$:gtQ<4#SG;Tq\,9riWck:=Ohs9<(h,09RC&0W
J!H4)"2utR\?U4^.ph5rYH8iVFZd90YSl4Fr=aH$Tf+!asTSj>S$r"&Q0H+<\/AuJ?8[a?;8
q)Y*KSJ"Rs_t/P:6h=VfBkO/IO*e8)=h!:om@RQ32d&'g:qnlo8n,/(dXKEB?p6HfZ*A!'l7
X/\Uug=:AR4L")iKu-8tV;1KRLgp0p#afQhQ^`TYMRd%sTc1u/%3DV7DA%gDRAhM>40d1Ee>
uL&UYp@G_+h6Nr/9IGjRpt,#u`*#(cQN"6Qugfn;#`4r0:F+T#]A\.<1(09g=Z-`?bTDZq%s4
g&Pm+,R8k_!42;<^1%o]A4X,TXmHWX2L8XBo)CPuc;NVnX=qJgr2Y'`\4H=BI-DZ4oE/,KL-M
GAf(^04cY;oEMF15Ruu7)+W9cdEY@U+m#SoDu9`ALntE((3o:=qYh3XQ/3Oe:UbQAg.pM.H.
lVR'H]A_#-8mKk;hgH@+gfcCnaTjS"Ens1]A>)]AH^7V7"92P_reD[5Q6';0:Z:WD@UUjZQ'BPI
NZ:m8)rioQ+bF;VEHE;W7ES!k.=ioPj6]A^(S"ii8gNq$6HW,[3dAeHXXUl>qllgBa#J.<Z:9
cu7N?Bt;H"e`7SBUSZ):`h[jeTmG%,-OjBQQ(`8b6P@eF$$?i0=_]Ae[Jc=>sO]AGM6h,U'V*G
0Th\g!2>GICp>2BD&B'd+6c.Xfr6mG=bM**VG(2.ll+gaCK&<%A"Wa_H'4SR/c+;h9kjBoGP
Tpq0_^-+&IMUHm)$JCXp+m_'VA^mqZ,I>lh(O+C=BUDKj39V9aeKZWauukj/mHMZQ1C.YdKS
>)YB:Dp>\uM"&IBP\&+WsV^Z;8H/Me+N<jKEm'M3Sn__(SQJ3^f;*!HVT20t8\EVQOYLCZj6
Z3,2bnb1dD"0nJ=;5N/?G4TX1<T4[J'6U$Ee;64`-gF*jW"X<J:=P+]A;((WsSZ!3EU/(@\%9
3FdOZth@++P.)R8'*0Dh>G6opB5!$?a:l<WZh%%8P;"3lU!49/,di]Aq9-9bl25nF<iCeP^4b
:o"P/~
]]></IM>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="1" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="190" height="29"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="770" y="2" width="190" height="29"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="chart000"/>
<WidgetID widgetID="b9a5ea43-44d1-4234-826f-667a2a6dd755"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="chart3" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<ExtendSharableAttrMark class="com.fr.base.iofile.attr.ExtendSharableAttrMark">
<ExtendSharableAttrMark shareId="74b93f04-30de-486b-8515-f94fac227b0d"/>
</ExtendSharableAttrMark>
<SharableAttrMark class="com.fr.base.iofile.attr.SharableAttrMark">
<SharableAttrMark isShared="true"/>
</SharableAttrMark>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ChartEditor">
<WidgetName name="chart000"/>
<WidgetID widgetID="798c9f2b-3278-4647-b5d0-6229d6ccc099"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="1.body背景色可设置为#021C23；
2.试管型仪表盘百分比标签使用自定义展示值标签，调整标签位置。">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0"/>
<WidgetTitle>
<O>
<![CDATA[销售额排名]]></O>
<FRFont name="微软雅黑" style="1" size="104">
<foreground>
<FineColor color="-919809" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Position pos="0"/>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__4040392903BC97AFA0731BBE11115636">
<IM>
<![CDATA[!E(&Bhhb0)7h#eD$31&+%7s)Y;?-[tGQ7^D+p\AQ!!$%!_Lhgg+;ma=5u`*!m@=Ja'\D&hn"
7YDj`3qe&Aa+W=LNa;$7^Y@+eg)/!\+gO`KEcS?3CD>J\@`Y$Ao!kN%m&1`?+A#7MCc@?3CD
cJ%d]Ap]A<eiMbJB?dYIi-P5%f)-*L::"4l:YMS8\Ds&,f4Pq_,U=-'/'N9J.)barWWJb+<j6V
1l7/MYpkEoLZEd]APs!8Q6.cA4\626&G#b<J5BDd-^GLfMPPra7'_C]AOgH5L&BbET7.R&X^f"
#DDQ,#i8)&e*jb4jk^EI&X@5)(<.guKto$RNC]AH@3fcJMN+[(oRGYX#9<R;^%e/Xe&Q(!a3d
Pfs`]AMu?&,69gU6Gd^^X4A.4USLKd=qkD+e7+0NJ(g6*)!bmdX(m((Z6a-(sb)3i#ZB?YGH2
1ujEg[_O.4t(sPa-NMUh,`Xdc*i-C"Yn5]APN0r<\`Gd\WfE]A3aO3fF[Q$H-WZJCMIdMTkkDY
j.]AUKl.OrFFjlKu?dRn/7]AR2P*;Ee88.3HN:.4]AVL;O!0JP*M",\gf1bA#*\R]A?-ZTZ]AmWoC
+1_RC*e9h)!IuE3_1fK3j:-/S"b3o2bEZB93HCe.nR.$Q))9jCJqQgf;&cNY0#5m\gCMNZV7
@d$Wnk#qcK[oo`i@?.[t=]A>+-o[Z)"CdAR\ZcDUR8,<_6)h\g_ATG?;Fpl4A*inF-AEl#6Ef
rq7CNh,hAjVbls*!Q6IN4]AVjMO-<$'-ZUJQR0Xt#5*61`"VRNqM$2X165!(iaA3@ti0!Xdde
l(uX=tCifaC(=#Q^+%:f7jYj;Nl/0.htkabms_cbe)<Tr<SL_8lt9!@7,f8CTp,BlP7.DP0g
(*.VA]AO-(205d1+j,;&aq+=Wb?Ssq*lQ-9t89BIpa,fP36OMAGEQ4W+1.n1OE.I$n*BAcNM_
/o[R5!hj*1lSNS)i8hi#'BtKBusm?66IfK&k^>0d=+7+H_EM&KY5N7J3!a_K^&hrOpX.T+,j
<*i@;V`5_Y+m9$*^j!6S.D:l.76Z)lAFJAa+*<B:JLr.U<>OWmri#`Q-2\01&#0JPnE`%Of1
3^ee"09SF<"GgX>"$unf,^_me7=QJD^'G$PKS2"A<qd9NX6g$f,^b7fWN)"U<n/-#8ZHSmqI
3Y%![N,D['GH`?>FDSGhm[Np1o;qqtm>,l#5)=p$;X!3;g?RpUq)s\nD':\Q-r2L*%W/hAii
))%3aR)8LUu]A0A49Ah1XrDbJcYr^+Ta==!Sd6J:B5TbPUSQEL9*_5!r49$+ah8LQ7-JeudS(
Wd&Ii!\QgZ:C$;/bo6GoXn)k&C#j_;($nq_5!WV$`*T,W$;QMabp0FGpN$9kW'PRn7"C0GU.
L,S/+6.>ui^fN'QBn-O+8+j6.OLJnH9TO?5l*36K8RIdqO03IJe:*_6"2Ec7)9A1C&L5"."k
;*IDEZ8,&A.*<>]AOhQL3]A9jAH(kEoZ#t4P'j)C5Y$f2L!0;7K&$QdJSZ.qo%Y=+M$V'BBEW2
'T(L'8*.(XnL0,Bu]AKi^>&98]A:Za!d,de/J/QEKA7nP6r+3I8jNb)j=X?WJd8j0X*Rsl.D]A4
3]A#lP*`JVfUh,C=X3c'&CO6GKAD;`u\WP+J0s0b5FTaSAtN"&doS=?of%DU/7>L(@G"'Ee#]A
VjjrWjS4X\XR%AKc`Yd4PlpQDf^qr%#S2Dfpd/bPHiSGetsH;dW\g;9]A+5!P=FN#^)]A"NUC,
ncD45:rB&T5F%5dh8\.u6@>Ki'!L^dQfXJ_H2YT^(CoMib`/Zn/Imeej&LLZl$a)\d_:Ri.B
]A#]Ao(kor8[F$,e_1Zpqk!ZY,dl1jMg8OkY#*':"V.#T>88<9?1cR\7EFS%uAfRnr`IC!L3'C
Sp?RWpD[2>:9D0mW"EF&+D;lc_MXX>T`=GVGpi9NnaAHr@6WpQX35bU+X>!mGYb^mHo0g./I
uX#F5WAnAF\3-;5ri0!&:!Y6N9*,?4,R)8mEdFS;PO0h3[pAYFYgh+AuLKjZUGe!Eu6U.tbn
0;lXBE`eT_iL1g%q8_g5BsEor9k0)7\KI%T_86O&-i[nR<RT$f(6WQY1:2`qch>$s)%(IqnH
u*G9=eoIJ[4EmFt.=HhXtCBfUMnqO[0/K:^iRdVnmJQEtf&[[<Vlb@9%oS5ut>U$qBOSJ^7T
4'TqaM8#TDGI3aBI>8!#V=+od?/1ImYmiL!)u:%^bAKLR)u?^Sh.hLS5(1TibZA#SRSCuL_Q
?U7Ad_:EAi$((RqXc<o?#Y7bWB<5dqK[;9rFk"1e0BnP+I]A%R\&)PnjZ:dY72G?H*,+DR@Lh
hYo_p/X@kGF>_?.jXsq6C@hj^p9([U>\HXa/?\SKW^^B^`?+u2*fd\fPV(7*M-7i<i`V>Z4A
r+HE.E`Zk8%9iuDsXK+#+1F7/Stp+aHi:+8sbpV-;h9D;G:@/;bY1V,b'`qS8=':EK4+.7`W
Ui3lfA]A3JJn"&"XkQ4CEK2OhGtK;89)=7f=Zh);.dla,_r=XSXhf4%$Y4[$.K@+:S-nL8rW?
QkX;fa!1^sj,R;eg`!tVRgC5B[M+8o6eo8X(q1&diu4_&$q8LIJIN/a9AOe%CgbNG'L:Uod%
D=PpQ>GIXG6V%K"ru//d(.mIs)blqi0_*oM`kI5c`tdKZMo&*'Dt)iF7@'G2n9AIZjihmioC
6>TgY=62,0BF1#;L2ekBHD`m=eaDO+-pT&itdd,GS-.f3Er@.iBMr]A1qQ_\C2P3Yn@Ms6aVX
TD?pEOEGXd^?C+1n>8_PldL2=%a+DSJ)jC'qr(7;o7)%:5aZRKq/j[(3E0Y!p$,sq&SMe:j`
!Eck5",/!&*LO"g*j&Q^#sMS&ej@pIjm9`35`ri%1Bo)6jsWt0&j5'UY.oAK:sNbHCkL[Ch]A
?>^^NS(Af72m7X3ma"-'BL>R$_M"Jo#dat&IA&fu?-&uQm=J-)7mB)m.H8j&6,`$Zioo1hh.
(LZoS>SU_)C9-"aeAeMZ]Ag=0+Cod]A]A?T`da)Eh?-4,$noC>BlF\WG;m0Go^@Bq-fbrDFI@YN
PHGHsrDM7-,\f%jKp+Ha0rcUq\i6JMT5Q(N8MP'mXPBuTPh=Qn\rfNWGi8416&+Atto]A4?sQ
h)<uE4+WOi>[K3O5DG25BFH4i8X4%79AoD(Z0UB;0(uB7G6LKWq-$UeJ4-;SlOp>f2S)9eip
-Zp7eFak/HrG(U%/XI/+-*?GD*hn6C83o:"[]Ag?SUAR`^C3eJ3QJ<gN^XjCu_q#N]AX6AH`n=
Q9<:&?1d@!c%:_+YN=Y+Gko`/q^t%EPB6HsDqV\qDJ_T-qp"e(mTa+Akk:9Q#CadYIs^cbI*
T,-;;3^q$epi2lbD]ADWVILYT:!1_bV>`TViH!Q4`SP;Id@;PacZ$^`rGhii'fkXgFqR%5221
tH`R>Dk#hKKhUuIHcLrpiG%A(M[115A)bD(RT:#k'Ds!T^ZRM*$3sE^=3DEH@:$IVpRnlUKB
*@+.b(bmM5jhRTghFU.a-&CU>aGe\VaZ[-%]Aj!k'VUaRP.TD#'bhebM9@=&QQs&=X>IgkP/h
T5R#OUfG=-re`lXR9.ch-cVD+CI,UAl-R#Fa9-jB&ZM^6&.N`qj-;iIfOdirKnVeAc!;,NKG
UEVFb4%:JQEX]Aj54sDiRo8t1&8k&q:`XE5Yr99<YpeQ\?;[cqCpZ^&.0ucSpM>_83HjoF6#1
&8`*XMP[)#'XC%2]APA'kQG[4j%GgD^9'05*8>5^PW""=e,nA.#*.QSHs<YW7-9W_Oq_1*-tI
&7"\gE;s6Ym$k7NC_;L>=:&IaYiIg>YYuGr:)[W)fGEq7(j-;aEJ*^EmgWl(f1`k]AkC"RW=W
(qY7$oP?b$9'!sojT.-YAe`f7\9u1\oHcNVJZfY?%_I=NtuiN#5qi"NLUa<qO=m,mDH9=I2S
<@o0Er$@jd`U;-UN==h&I8M0lbN^^be?kifm6N\'%Q#!FtRcM*(RLI&Cn`<b;(UUp3Fn2J8M
"%S-]A5#g/H]A<Z!>^>=J)PC$Su#J#'VB$%'u6*!pGI%@S6hgJ@_UuP2LX/BHXM:8OCdkPoR9h
*BfrYHP&+2E[-[f6Umi!oOo/2Z^K3[ogp'R4PpZYIk9.I`P9nak2(8'fpg0>Zt;]A/Id;jj'M
lnnbimr3&XtNugH1r^qtMcR3qk<Q>XEORCr":%E[Pf-P]A+\[*U>i&s]AhT\%h(,J2(F)YEWYU
@<uUVnrT61@4BDL0bNbiLs"R"St.+qa.3gL4.jp%JrhVTNY%uHAu&uZnH3m5f;Fl_Vi+AKCn
UgkV[[[ToD^DU!5PC"q3X,eug17T=aJm8-=P_=OZn-O4eUsV=SM!#s-$`kV7CW<dKc9_W_5e
IGoaY;6YH[Hu?TYI^eT7Z&l[IqJT>GL_B[>Q6&5G"KtPfbYIpYDnG)g!Nt54q+6leP<>Jm)i
g:,oiFQP"u`6/2!+/IP.Od0ks90"1HnbaG:u\$pR)SQ&'DKWKaqM.^.?=ImLs<EEZZ5ooJ`M
jXA6<13thL?+A0)lflF"Y,InKM1C\Xj;fZNgQ9.X*jR32]AUQ,hZ:%!\*(F<?jmb.e>o)E4n<
EC64oR"`M2c^7aI>^G<Ij]A@G^+QrP=A/DV<c2uW(q%>d*R`9)@q=G*Eju7\CH=Xe0j!rGks$
ni/,.AE9ZBr4nUO3)mk^,^JNkB+T#dH;_&N"lM]ArUW\qV>a7q)0<D`9D&<.7r^G"D%E=p/d(
7M[9pM,85*d$2..:U89h^tLeF't(Ym`"(2,><V&-AB^=N=p.'Ym*#USN=ri=\\im-&Un*F]Aj
nV=&3T2bgj>C"?LW:+7]A5/LAm\n8,'O5BH!9VE+F-HE$uF%0$!t5M&<W8r4u$_*=7-Lc:%B]A
I20(qo\i.BWg^-n%&<5t>HU%6qneBFF:mKh(Q7_k$TgXAPUj0,^Fig1*8iD26O&G*mThL>u/
U?=i&,Mh$W&(7-&Njd]AW@O5d_IioMTAW;i.G`Ztf-5H;\O5)IY$!HShpFJtJ*?!s7lslX?XL
>GOE9lWHKl2Kn,VA4)N[)&>o]A&r-'$fe72VGT!KuWgS`-,4*Z\cNrLtN_-V]A/BY`s1[,'_Q1
C&l^?)7d("cU@8a:*E@%fXQYRg.hq*-?tUrfk9C`^s9EqUNZq%^CQkEWT;>:494i,:g1B(^g
[Nk7Iu7S#>r?@>#2Tb8#a\F4/(G<?el\(F\[')rJoGTG.l]A(e,cc2hc0#;cFr+i1V#!Oo?XR
jS9p`ndUaPFL+]A08fB\klq9C7H%T]AF]A))uXaNKQROC3!Ah]AE`>2;]Ap=XQQp]A9[bN6`Of*GcL
dCH4"AbQ&LD5f<gj()g;N[^@eE-+u&\SjUGbCg>,'UcbSTo*sLq`s`m-OUA\W]AW'hRdnNE[R
,-ah7.f-iuR3RqN(Vi0J.@E^-F*met-Wj:8-^??PlfD6n$1"0-5:jNBjW+r%kWb`dNlaeJqH
Mq<DmZo5a1Oco&=rE_$qY2EHGLB1YCI6h%'6gVtZ*LIC53o^8pg?QS@4%o'+$"pg,ZN,-Y1D
.8TMMHmYKV+N1\^QX0a`u2I>OGb<'98JWqkBm(^l@3='MX#::.=T%=sNgW=RLDGN90!4<%*&
V/CXh&Y2mmhgslU8Bl'(TfZtR7D=&";+Iskj]AT(t]Am6&67\PM=Jgejk@o\naCNsEGTBu.\$5
a$PH>R^M@7qrc$C.SX;6'P!PCIIXt8>hRII7QiWl<\>T3ta[?//Rq]AC!'^eo#1?N3"+Z.4#;
MDoKD0ZC1ND]A28^g:DIbP]AYdggcjK9qVdYJk9<L;VMp7n]A^@]A@)I;:!::;Xj-YmL8BD07H%k
@CtO?+msk1hs?eU/U<_,W$Z_J#i:b]AQ4'L5d'cDl]AsPr<d"X)DVG]APEOUQVh-_6t<U;M"a_j
*;tM?h6>kO<aAGU.U`JPbuABpUn-GiCM53"+Z042^99`$31b,"h4E#bINW+[(oPmL4"[GCh.
>"T)&#^93OT5AIF\#@q+G;d[*8]A<=kuEbAc*%rrb7L]ASjJ*Dh0VP)#R79(&2ThB("1M'P\*5
`,e<Q]AaGFi8Jklr<$HsdLPu)`6ON-3tG,UDLb]AJRb2oVn"_BD6T>IhEp"6$EW4gp0"I`POAr
#p(8+=g4mF89a$;M]AF/!m<0a2l1C3!D3=&o5EqQ,FMf6V_cS@^8&+0:h,7gp0GAPC[0d>(>#
Z3B,Ep%/Pr05T_j-"G-.]Aq9\_[V`W(mEHLPJj6%DI/hF65P&aHH:D/FqL58EpBretjqF^@H,
o/HghgHhNMbK6;*6C?,+ZT,jJcAa`@H/Lr&kHp@_#DFTF<iDa)WPuU'W7iDWK**4E1_H(7bW
mO?7ae*X4:<lBFAMXrQNZK:XZi7I[)sr>-L_:m\dtoPRA_V>sEr`<(</pd!rV.d=[3.pIdE.
F(AJ^ZQB)d]A[Wg\A<dsBD5i@6r=hk1aKj(PZGoD5\^,KZ=Rhi2k(MOaP@?ecJBqih*1FNSuK
og=Q;]A=C,0TfG0V<*r]A9j.?NX0:[eF0?59Y\3pFi'"`Yd@,+/!k-3j7=Q_)oF^<PnYs<J#ae
4&5tiq0Tt-N3Fm<mbIFCq'oCB5h-j"*k<MOV_CFD!Z6U@.X5(:6o]Al4Y=-nepNio=X\8*#X&
RL0^e2_Q7B[\A,om916>*/mE[(:fP5E<ZT'OZ:]A3aoOP_+Yqop<<)O5tqXP.-bDhSi4fo\Z0
ojj$EMGQ9&cpEFgKT<:iT#guiu+?4Q/!Y)u`5Ua`g1o,A(/:a$J2gU8X(_ElKFU[2n4%o.?k
luMN^s')]A$=7$/jJu6GmV^b?:7Ar<,m_Kp.g=6DH/e`b*p=WH+a(3VSTpDL7.)&*>BA4KU^&
&]AI2Yi`:Ttp)RHnM5kb/.:Fi[8=#sQK*=a0GH[N4j0hIBsqTA8h_/t?if4X.\[d9!Hi9FJ&.
,kgOc/m,RUD<264+!pJ,0udBBNsFbP4sW6TSL\pW'MU_kWOcfbS]AS_.Q8F)P,!AQZg'(ie<N
:2`SM\:f$]A]A>N]Aa*NU.U7S@R8nKj-[Mu:.TK+/'Fjh81o(MIi,_^F?bhl"+[#h5ao*gR]A!J/
Ur<sT-[,?`9ZCg3Cr0e;;P.0=njtqFIP>^hm6%iE2nuZLL/AWi>_p^BtRG:XBASa:_g).rf#
fA$6=0a96.,%Xa]A;FeK=/f)1!@kX$"`Hq8AJ4.'_n`6TnM-'Z8QVnN6=cT!"rtaK:XK;rdM4
'R,sR\X`Ik'OZK0:G4DFfO8mUlO-sdY%P?++4b2)=,jc7M%BY/3g*Pms-MlnDK^$l-u^7LAr
9(:Ykc/ASO=7U-&*7M>@7e6L9jQ<J/.cAC=!Bk<\/M<I)P#W'VReG<Q7gFiI^F<#L/@fgHGi
D`'kht&AG8.`S7Zhd9161-mP/gQLa\k6'_S"u_)7e@/Pq$-`8XA.gUL\bk-<8GJhAJ,fX&P4
7\RgEN<:6iFP2$`\L,;sAhd9Z0#O8XW8_;L\l4^_78eu+$i:R]A[7h73HiR@UOa</MGf.-S;o
"BB>e+;B5#&LhjKeF?YN!.s^iL3_cFClj8I+7;[AmV/DD1X-u4$#'S*Mu4Cp\0\&[KeW6GaJ
k7o\i&m#<E3oEec-.UoRH<`PX/Cbf.l@*ii8\L[($al25n.&=G%E!A[^`,^A;tRP:Y0>n<MS
JgXp%3_E?=lkE1-(,A0G_%jU4771=+g58\o*75E9,-+*!oo.\:p#'su^.lqoLJGYfI$3s3qW
(NAG1P*taotLuj9KQ%j]A@OgP6ldHlts#_R@HA83W'AK]A5$8(?1LC(L[C0g61.59hD%KIEjm9
!V$\LS4S\#56X5EUC<c(/402=+bhqFn"T0)8TGBDIY#5G6NsjKA+!/Ur:o#f4OJcp!RbWb#9
_-;r4hsZl6<LcO9t;e'1PGGiM<&!H6=b4D>F"j=ePRr$5DquA""j;A?g698Mr]ApQ5NaOg0IZ
h<9oq:YE^oV7EbBF\K07&]A"0[[EM<0cYc,cGjVr.j;R#sL1F<il#`[Mt48BiYGW?>ND$FT$l
0)ECVd1EKZ`?besaW1_N\WR[O_^,TRO?7HIaUnR=@b6Rsa]AGI9ZN.]Ai3jGE'iY514QJD9=:L
%IOa9O8?9u1Vg_s@,CT`f9ke>KGYq'COg#iF1&+Qj4Ik0C-g/n.]At:h:*K.^/'S=i@+1mZ;V
.BpnsZgf8s(jR*aS-GSO=<)ftem\E]A8:@W"a4$]A;;_'KA/a;r]A(UoRHlkG7Fd:55S?HV!\"1
CDCjSLo'6.[.+38BW=VH;HD3Luf*eKpJc#0nLc:5]Ak/^SlI-'OumCWT&?=bHF`?MTP)X\Rms
\<TB%ljSpoW",9&c7l6fl_G>2,pfeP[Q=5l>T&[0uP<4Hs-VSO]A"43qTg"47A]AOmub=Q'OLG
rgkQ,VF0k6X&Pbq_'Il1p+[,VGi1,<QeY0qho"@ul6s/"iRO^uHE:#pG0)q:H5.Y$bN)Ee^E
:>(prBu`<7M]A[-[N>hd/kopiSL@`&4LHe.XAJX)>GJ\F"/H-jL*'7NugH1oOs$%_,%2ZMteQ
YjkbW>-4!iHFj5!JYU-K>]A,j+]AoXkcS,^=hkH!PHGr+[H(s!4pBnZ+^)Aad'pYrp:d6b6;eO
uedPCWm@PT!C4*B!09i3a&o:bX8r[D7eL1PI0&fS]A.CX<G(ZU/'ZicCE[-*(DGe0R(:8t<g1
$.N@->bY%0X+a,aI&15\%+j5ZI-VW2/`)nXUA*$6n7lP>[N&X?hjasMiHHL/K[SP0X7C86qd
B^ku*;$rMlOo.0pKN!hdOAgh3E"856'.RdR0O`AU3D=2I*$K1_'W/a8+b[^hU=&1$M)rI&S/
*G[*!;IRY&&_')^.Ch%%nFPR%Ruc5>@f6eq'<s&6ghSR9Afk<[X!ZEbM:c1JjR'e]AJsG\1(?
FL*cpd)GU'?Xn\f4rk^6Zrn.jt=Gf+sPRO9(lk]Aa@ZW\*M-jItW2BKrH^e>4oU5f'!%.K6SB
=\^#^]AEqUqiSNNph8**>(dgf52f!)hHH;@_N(MNe1e\BhdeU'E9g*Cf/$CF,SoT`Dh^gtI69
jGEE?QN9VAV\(sL"8eh,OINuQV!EMXP^:kN(,$OpoWK2de,d?A8fof"d*'5&Uf^^_u!NsjWD
3sDSC8C<FI.]A\GId4@WY$(]Ar%2D(4tkVVBqH3]APEIG25QHua/d3'Y,ek^epuMJLPL0DX^@O/
9<lp0R:T$bM\=^2R2&qo,3c\"=18GPh3W%<lPWVqn=pc+$t>ERW`IYH6Vs]AsI1X9]A'inB(jM
s[Ia.JY6j"YB2-Hk%r.gK5-0V>nPN$?OiK?M@o$j*SLg^BSQf4&rbPG+qY?l>XZr0%m(?5"Z
hIX;mJcE_[6NLtY<D_d7IB?s.r3JeYC-?@_lDm$+'1\AQ!aLL:=6BapIf7-4>)-_U>Y;-QR,
Wb?<5XiI/3.)b?$?'^4,b?ea$9ocX4AcXF5qTL:2BtYcRQ;+2p+`Ik>p=r;,I=g:RYj2&G[\
5!*nrin;`6jjcTP.]AqES]AqfE;Q/]AsQ91;W40,.H'4B#(jmW<p2MA&cXPE.gY8NQL:3:?Z.M^
.uR0+-BZ^VE(sp\]A<kmlm/Ip!2T3RD1nRSFP@OM&U=qE)"%A^j42Lq]Af-J^GgDjeU%Ca?N&\
4q<D6)C#5C%8O)+sQB6;p'R/ebQUR6YFc<kUX$cN5>@0jjrrj&BSGVEkk]A8[E7%V0@+UW92'
63G$HL=slLpNKBiFf=q*Q$--D'*rp$H8D`kdekW,0o8W$d6d^5Pr!>=>%K;9^!qTT"`i0o[L
kRR*ul*Kq+kC5'7o0J$*)@a`D<O:S)D>Eq1c!K5l784eh>\j1.FET]A;s)@?-ps'6s-`co1+_
agOLU0^/%`[YQh-7uk%f4EA)/i*k+V5&S!ui@EZQ#Hp@67*G1>[e/=f]AB/BbLu#[Hc.\?`=N
o"2Z'_q7VhOS7MO?PM[$\+HLBXEKmuHceB5ZV`_DcggM]A(9X!>`E(Z8"/DD7,b9F_gU5>IIq
Rg60G%bU4pIKhj%LG@kGCT?Wi;S!s.`Chc.N;b$@m))Q%F9tf$)Rnc7Ch3`qb]AJ6OFfD:KO(
oF*HBJMSjI1n8gFf?5(25s;5f<-q(=G'_`cJ3j0>0Ne-CWtR8XZ"5$=D^61"U_u0UYooJ$F5
u#1n+K@+I9)om>ApD;jLqKj9W^[^skf]AZn[36FGZu4dLoKF6kniU;Q)JsflRY,38)51?@`t7
-T;pV#R)]A_ZA)+O1)%kUWJOP1$94cUNCH?/0MW3O(rn<uB]AA2"6P;'tJep4j3\2s+p`(.1+9
1Tp"`^.ErAsAQU#2NgRGhr26-ibG4ErLDE9F5^h>XaUN?!>@!+Q8t:jl4(3'G^:r[ZJAI\lB
F%I"AKYjZ,deA@H@([@q-;!.sXSIsBq25!$t#'>XKJF5[i%cS.&LVPi3<pN2`of)j:6b`6L=
#d/QhBtZSFR8]AcCA`:*<r1RkIJ\KoO5_7g(JUG#!!!!j78?7R6=>B~
]]></IM>
</FineImage>
</Background>
<BackgroundOpacity opacity="1.0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__587DE609A833C08D9ABBB4962A288E37">
<IM>
<![CDATA[m8s*f;Yg=$gWWcFMopu+mHRf;3o-3k-T0@N-F[#5pR;Q7;KBf('3?<MZ8=AD`Y`^sDj4IpPX
o[Cdk/Td"V#HQ.Kr]A]A<!3mtGZj\9=+&=)4GW*icglO5?H`6,T(bI[Fc5>s',-S3Vb_RCR@%g
3d,"`0kptTYd(p@!M$\uXgA=9/7d4`/AFcns4kZU@ju[J;]ARTOB\$(Rq9-1be]A(YkCS'D@jq
VkIgD2?<tL7KWO[T"pIRQM"ulmVab&1fdS,VTUUL?o%c,\XB`(=p*=h;ns"*+_(._%B=djoX
]AI$5]AAD-H3iIEGQKl3:#ompKZ_LROH\p-;/'d1>cuUR^s>"s(UgmSE.P;aY5ZgM/Uri98@8K
-4=dkQ-dRKHabN.;&^$OfUY&c/3Yf?DM).R4%79J7YCt^Z@.T?oZD`L>+l1u?;rX@X:nZ`![
2FueGG<B#7Z!l5X,eOW4(#a.:6NLL?=5UrTPh^8I)&gJq(;]A@%^/0%Dnt-GLR`,D\>+i$-2:
PVi15!rVm(r,+e/W9d=iJ8a%5?=:,BJ\B.]AG$WGc$ld&MN/5*H!jH7a9Wan"ZF>ZFC%!nXmN
INE/E]AHl#CM!\"p((o=qp9/9J8X!Br4o>dAgrcr"F:IHZPdNkTmd+s7ngKX(UbImKj%\uflC
+G_cDuW]AP*b@TDpbVY5il'oD34Z8ShG2j#l`ugOlZq_gI?I:crf9/KU4_6,X`ih^P5ukL%+)
Z:Y!MTR)p#8'5rJgk5+<+^//Y6pE_Z>Bsu(im<WDETg]A6e<fuJf7?22=`rEK>\p_P7rd%Fe'
@O6`\)B>\6_2l@7[+>.O=OjD$>o094_Vkasf3,X7Ahq#8uCkefId*9VQu^6P>g,&&h70Igk2
N0r$]A,Hi7c@F@Wr)dp]ABaB*&YZe)@KC^-WZ,`bK!>UqFS/ltGo[IRhf\,NrccQP-0Fe>5AS5
7WBMqs0pG]AN!er.J@D.0=h6hCHWD5dEIe2bu)e]A[TWX'9m9FLRr*(u5h`Spg&O:-5m"EM[sF
s'9fn\WVI&-7mWm022LR(cZGU`^26=Oo9IW&G6kU(A^K<a0ETR29.G.+L!F4(`33D9IUkFJ[
'XWggVI3dG<fZ.S@W7[,^,h!;"R^3k+.^3uje@*V`P/DQ1"Fm-]A)mX\RZ<do9o&Z01[;;Y>^
P9\?d0k8=.$MLWb=8@4gnXY9m*uU8=N7u=&-hDl_3I^.),[jkbP2eEH[>u%"Uh)$7b4RL_[a
&_u:I<C*!p512IX(;Z(hN07MV]A8,\$5*JAR=A4u'9Y8=:-=9Nf-nR\"pO*3KqZp`P:^[]A5nM
,G.70/lqaJO4D*4V#^n;$eH5BDOISV.Q8e^i^UkD&p9\=l*2+^o:h]AOTZ@;[se+U@4p`nc_-
QLo8tEBh`[\[grCi2QD?-LGWFu;6f%lHMdogIG.AR#G\=Q6[nZg.@8iHWiKoUIAB.Bfp$Cdm
fOg&DHRp`!:HCq6c9Y_3,\Z[!!qVWc9lMJZC5ULHn&Nic#dV`i@i*<o7!@a@I2&E5.Mk<P:U
^PM+nVeS1i8u0`;$AMk44\,f9_`\-",tDP#G`0X-r`-ER>)(&jH9:Z"fihiOIp:=%fc`5rQE
Sdg]ANLdP5ISjoE[NiB+18r2s)/jhIHfkA]A4Hkpc-k,Xd9u_Rs&#b4OH$BFkV]A)"(<&]A6`g=o
P!s_^s!&O9J'E>GSea3RlI_Y%1]ARDW`g/pDB#isWuJH3$9K-$Q"sa01$&CqL71(c5sPU2M!i
%hJbDLOn]Ag*NDIiigOg<5)#&ah:K]Aa$!Diu?/A'Xa/fR(71bk>sgJtO]AlDH&)a7*6+Mb.`!S
b+r5\)um/Jd<K=Us0,dFWJf)D'p2W3![hb5\Jh7tbRkGRLQV_PWY1<AIa$=:78elN_(U'a]AV
/->NLdQ40W+C9"(j8-O7TA\9+e.<H9>bj\FER#CYH_EU?CNk7F(\rF##i@V]A/V]A<>-KTNB=*
J@"c#,rHPB!GFa_)I=6#HnD_D%p4c,S#cXIFFT?OQ^d>MiGpo.F$;k)'iib?]AcM:ACr8O.D[
!d`77m9;;b[KZh:"N$`<t3[t`^W0bh8GDMAk02@<2eXB2q>F\M$P_>"&Me,L<eTZn?K"R%sn
>,c8!,-Hs@9!qnj#D0(3MQij)u<3Vg/D`qoiJ#k+?qIV(l[h^t(T,7EJo?\S8sV>)[=,.+L,
3O#(<%[Y+LXsHru/N.?U#oSh6VQAC"$>i$[0Iekc,)U3F]A8tk#0R?g)7Kdf^OC(IY/`-/F6*
SQS1T.cE$GR6i]A7V<!PjSl!lR<TL<9'hn3ie#h!pfJ8YLK`9-.qG`L:EX4^f,FAbk5ceY!Qo
u[hY,A'kh+(cGAV+\.A:L\gkWhbL*PlX:Ls7G2MpQ_3pj7B#PSO276<tIi5c[)7&C,kO5Y(\
^MCJ_nMV7`,N)8cI7I`!YN!^4TVfL-!k0h-<UMQq"V.Zq2NJM>pSqP(VGgeU]AiZB3(@K]A>;>
3YEK([=s$H4NihRo-0p-?QMCjjc=>Y^iDOo,5Jh@9:aF*k%YLJ>WA(M+C<7!F!EVm!%]A5jL#
5mEF@@ur^<Tp3H`RbDq-]AiVrNfUMCEqp8;F\5(ua)"bh:2:3+_%AqK'k'>abelUcYP!.5P5h
PGF#!StB!,O7a$abBfI%U5o,U2E'pu%fc9K@,6$%]A@[K*+VD55C"s@Ka#*.&0@"D8^S%>q1t
D'YVh=g6F]ACs0:IG%6HHg%pNMMXfq&\WR[Gqn^1kr;Mj4?E*ZU,Wu-S^bGbGdYU+-N1<)`g;
UaqL@""7uY[ZE)1B[I;aq7\q`cQ\GG`/j(!-m>]A,LW<mWl\-H74iX9/=&CpauK$8%^T#ER$M
cbomW/e44[`Br!TFZj(f(:H/FPa!n+7BP\Z6&LMf?OjeDi2KXfTX]A_M'[h+[h?apl7%80P#n
>'ksbGpV-RQbj-H8XJ0(o>N,Mbdk,,M1K(!L"ead.EJ^Ne[$o0?c5D!'S95lB!Onf(ukZKP4
k<:r'2BuP`bZg(<%ui,q^"lh(us.:S`^?7&MNb8ZY4g0qK\U[(?5Rq6m!ZKso^u8\1(r0.;k
lF#.&lp8j;n'#qLb`jAOP[g'9M#TrQ9gh(Kl:uh2a_5tNYLVhjPn;MFCChsPf4[R[eI=EnRG
C6`mS=i;e-3'TQ7eTkE1ET\A%a+\iU;$01:L-*,FX3k3r"[f\9%6qRS"GHGJ$6DaBD=5fJak
LI$DFb_]A=o#nHWV#aQTLKX>BF4R31%E1X^?LpN%1e;70EVH")2;aljgR6!o7.fRtim_(_8eL
%A\gKG*6%s5"?5W37ge\;4QBfI!075#gm5FSX.+N2hp?CB%>MF;;]A4g7Lfo7JDSjfh:gN`V*
<Bt=tpkbfXGbRZ[(<bm,5Ehh@qd62hd=@BgTWj,IZkUeH/M4pM)3n5_qDWJ6+.Z"tW`B#8G.
0BiY`a1H/reFERpa?+)ba0<_N&En]A+pS>j0<$LTj!j;DfNqon!ZGS`87FUSAcBil/C4)6*A$
]AgN;,nYb>K0G7;loL8fT;n_G%%+*"InYA51P,A#a@s.*K%QNf0&O0VCi8E$?lEaLT_4,?J[>
i?2.'CDq$#f/f<;b`)k$"9_CIBtp0k&mpmS/$QJh<ECI'r8hFQT"!+WT0#=m`oA[7Bn#:^42
Q8.:W@!hMEbUr&6c0[fF<VD8/Q\DDAa>p-.iYVa65rl.M4QLq60BfVDG-!i(D&>iXLX37_*'
[0-g^!hq3J-^Y62Qg[n''ia3g9BGl0KtS<efiW=^ong8</(ULKoh^:>kfAldD[h3OA6#k.59
Y0rF*<]AGFL%Z#3\[d!b6b?-?$Tr"^CqK;M=uNI01jdDJr-qNcAgXc^b[;QsN)>R_N72%D:kG
`dL,JISH1,*^DDHm>82QPU7leD6a:jnid<0m-qA!rI_*J:2$7`]A4l,(V10\lm700:?uoZSlP
rP',Zf3C)9o^)Lk3KQ*)Lrjc*YY/?^;^2dss\\.]A$HJZL,.9-=0GfjfFComaB^*2oTk1^rYg
kG'#Q'+d*'Q#S.`/rclgN1b-`T>-pOf!l4qXHJoGlZ0"_s*qZmW=kOlZ&b0OP<*e"4!go79T
W(omuAt:0mc%ddsD5>+h=?0E-b'77]AOm.4<@h(mA1=11I=UHTGeB%*_Z4XOkC]A80]ASG"r1TB
OZuH1Z6Cg)bN@a+6;ht&T0,@a+>#dtk9,d;[eiYo3(ThHVg=$:V8#<&9Z)lBAV7$ZWCcY3iJ
atMEP.H8&I6K9di:@N),,@lKX,4+uIIc!Dh9q->Z<I%L<d#.k\$-LVQmjeF-[qc)qBEl:^b_
d,_"pCYfpX;l.F/WNZCD.@T'ZHCY1HfaEb0&RqMK*EZ+!,::&b1(:KZG?3a-Dk[/(_Ks8THe
^NZ73:H/7X~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<LayoutAttr selectedIndex="0"/>
<ChangeAttr enable="false" changeType="button" timeInterval="5" showArrow="true">
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="PingFangSC-Regular" style="0" size="96">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<buttonColor>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</buttonColor>
<carouselColor>
<FineColor color="-8421505" hor="-1" ver="-1"/>
</carouselColor>
</ChangeAttr>
<Chart name="默认" chartClass="com.fr.plugin.chart.vanchart.VanChart">
<Chart class="com.fr.plugin.chart.vanchart.VanChart">
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-1118482" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<ChartAttr isJSDraw="true" isStyleGlobal="false"/>
<Title4VanChart>
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-6908266" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[新建图表标题]]></O>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="128">
<foreground>
<FineColor color="-13421773" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="false" position="0"/>
</Title>
<Attr4VanChart useHtml="false" floating="false" x="0.0" y="0.0" limitSize="false" maxHeight="15.0"/>
</Title4VanChart>
<SwitchTitle>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[新建图表标题]]></O>
</SwitchTitle>
<Plot class="com.fr.plugin.chart.gauge.VanChartGaugePlot">
<VanChartPlotVersion version="20170715"/>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor/>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isNullValueBreak="true" autoRefreshPerSecond="6" seriesDragEnable="false" plotStyle="0" combinedSize="50.0"/>
<newHotTooltipStyle>
<AttrContents>
<Attr showLine="false" position="1" isWhiteBackground="true" isShowMutiSeries="false" seriesLabel="${VALUE}"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
<PercentFormat>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.##%]]></Format>
</PercentFormat>
</AttrContents>
</newHotTooltipStyle>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name="">
<AttrList>
<Attr class="com.fr.plugin.chart.base.AttrLabel">
<AttrLabel>
<labelAttr enable="true"/>
<labelDetail class="com.fr.plugin.chart.base.AttrLabelDetail">
<AttrBorderWithShape>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="true" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
<shapeAttr isAutoColor="true" shapeType="RectangularMarker"/>
</AttrBorderWithShape>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
<Attr showLine="false" isHorizontal="true" autoAdjust="false" position="1" align="4" isCustom="true"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="80">
<foreground>
<FineColor color="-1578771" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="80">
<foreground>
<FineColor color="-1578771" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="" isAuto="true" initParamsContent=""/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="false"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="false" isCustom="true" isRichText="false" richTextAlign="center" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="false"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="true"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="function(){ return  (this.percentage*100).toFixed(2) + &quot;%&quot; }

" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
</labelDetail>
<gaugeValueLabel class="com.fr.plugin.chart.base.AttrLabelDetail">
<AttrBorderWithShape>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="true" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
<shapeAttr isAutoColor="true" shapeType="RectangularMarker"/>
</AttrBorderWithShape>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
<Attr showLine="false" isHorizontal="true" autoAdjust="false" position="1" align="2" isCustom="true"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="80">
<foreground>
<FineColor color="-1578771" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<GaugeValueTooltipContent>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="80">
<foreground>
<FineColor color="-1578771" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="" isAuto="true" initParamsContent=""/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<richTextTargetValue class="com.fr.plugin.chart.base.format.AttrTooltipTargetValueFormat">
<AttrTooltipTargetValueFormat>
<Attr enable="false"/>
</AttrTooltipTargetValueFormat>
</richTextTargetValue>
<TableFieldCollection/>
<Attr isCommon="false" isCustom="true" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#,##0.00]]></Format>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<targetValue class="com.fr.plugin.chart.base.format.AttrTooltipTargetValueFormat">
<AttrTooltipTargetValueFormat>
<Attr enable="false"/>
</AttrTooltipTargetValueFormat>
</targetValue>
<HtmlLabel customText="function(){ return this.category + &quot;:&quot; + &quot; &quot; + this.value+&quot;万&quot;;}" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
</GaugeValueTooltipContent>
</gaugeValueLabel>
</AttrLabel>
</Attr>
<Attr class="com.fr.plugin.chart.base.AttrTooltip">
<AttrTooltip>
<Attr enable="true" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<GaugeValueTooltipContent>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: left;&quot;&gt;&lt;img data-id=&quot;${CATEGORY}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${TARGET_VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${CATEGORY}${VALUE}${TARGET_VALUE}"/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<richTextTargetValue class="com.fr.plugin.chart.base.format.AttrTooltipTargetValueFormat">
<AttrTooltipTargetValueFormat>
<Attr enable="true"/>
</AttrTooltipTargetValueFormat>
</richTextTargetValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="false"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<targetValue class="com.fr.plugin.chart.base.format.AttrTooltipTargetValueFormat">
<AttrTooltipTargetValueFormat>
<Attr enable="true"/>
</AttrTooltipTargetValueFormat>
</targetValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
</GaugeValueTooltipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.5"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</Attr>
</AttrList>
</ConditionAttr>
</DefaultAttr>
</ConditionCollection>
<DataSheet>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isVisible="false" themed="false"/>
<FRFont name="SimSun" style="0" size="72"/>
</DataSheet>
<DataProcessor class="com.fr.base.chart.chartdata.model.NormalDataModel"/>
<newPlotFillStyle>
<AttrFillStyle>
<AFStyle colorStyle="2"/>
<FillStyleName fillStyleName=""/>
<isCustomFillStyle isCustomFillStyle="true"/>
<PredefinedStyle themed="false"/>
<ColorList>
<OColor>
<colvalue>
<FineColor color="-1" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-10243346" hor="-1" ver="-1"/>
</colvalue>
</OColor>
</ColorList>
</AttrFillStyle>
</newPlotFillStyle>
<VanChartPlotAttr isAxisRotation="false" categoryNum="1"/>
<GradientStyle>
<Attr gradientType="custom">
<startColor>
<FineColor color="-12788517" hor="-1" ver="-1"/>
</startColor>
<endColor>
<FineColor color="-12785949" hor="-1" ver="-1"/>
</endColor>
</Attr>
</GradientStyle>
<VanChartGaugePlotAttr gaugeStyle="thermometer"/>
<GaugeDetailStyle>
<GaugeDetailStyleAttr horizontalLayout="false" thermometerWidth="6.0" chutePercent="0.0" antiClockWise="true" slotBackgroundColorAuto="false" paneBackgroundColorAuto="false" hingeColorAuto="false" colorUseCategory="true">
<slotBackgroundColor>
<FineColor color="-16635559" hor="-1" ver="-1"/>
</slotBackgroundColor>
</GaugeDetailStyleAttr>
<MapHotAreaColor>
<MC_Attr minValue="0.0" maxValue="100.0" useType="0" areaNumber="5">
<mainColor>
<FineColor color="-14374913" hor="-1" ver="-1"/>
</mainColor>
</MC_Attr>
<ColorList>
<AreaColor>
<AC_Attr minValue="=80" maxValue="=100">
<color>
<FineColor color="-14374913" hor="-1" ver="-1"/>
</color>
</AC_Attr>
</AreaColor>
<AreaColor>
<AC_Attr minValue="=60" maxValue="=80">
<color>
<FineColor color="-11486721" hor="-1" ver="-1"/>
</color>
</AC_Attr>
</AreaColor>
<AreaColor>
<AC_Attr minValue="=40" maxValue="=60">
<color>
<FineColor color="-8598785" hor="-1" ver="-1"/>
</color>
</AC_Attr>
</AreaColor>
<AreaColor>
<AC_Attr minValue="=20" maxValue="=40">
<color>
<FineColor color="-5776129" hor="-1" ver="-1"/>
</color>
</AC_Attr>
</AreaColor>
<AreaColor>
<AC_Attr minValue="=0" maxValue="=20">
<color>
<FineColor color="-2888193" hor="-1" ver="-1"/>
</color>
</AC_Attr>
</AreaColor>
</ColorList>
</MapHotAreaColor>
</GaugeDetailStyle>
<gaugeAxis>
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="false">
<FRFont name="verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="false"/>
<AxisLineStyle AxisStyle="1" MainGridStyle="1"/>
<newLineColor themed="false" mainGridPredefinedStyle="false">
<mainGridColor>
<FineColor color="-3881788" hor="-1" ver="-1"/>
</mainGridColor>
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="3"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="64">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=1"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="2" secTickLine="0" axisName="X轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="solid"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList/>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=10"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
<VanChartGaugeAxisAttr/>
</gaugeAxis>
<VanChartRadius radiusType="auto" radius="200"/>
</Plot>
<ChartDefinition>
<MeterTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<TableData class="com.fr.data.impl.NameTableData">
<Name>
<![CDATA[月度各部门销售额及达成率]]></Name>
</TableData>
<MeterTable201109 meterType="1" name="二级部门" value="总金额" custom="false" targetValue="目标" customTarget=""/>
</MeterTableDefinition>
</ChartDefinition>
</Chart>
<UUID uuid="ede5ca65-e5f9-4a7c-badc-89ee09d50293"/>
<tools hidden="true" sort="false" export="false" fullScreen="false"/>
<VanChartZoom>
<zoomAttr zoomVisible="false" zoomGesture="true" zoomResize="true" zoomType="xy" controlType="zoom" categoryNum="8" scaling="0.3"/>
<from>
<![CDATA[]]></from>
<to>
<![CDATA[]]></to>
</VanChartZoom>
<refreshMoreLabel>
<attr moreLabel="false" autoTooltip="true"/>
<AttrTooltip>
<Attr enable="true" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="" isAuto="true" initParamsContent=""/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="true"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="4"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-15395563" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</refreshMoreLabel>
<ThemeAttr>
<Attr darkTheme="false"/>
</ThemeAttr>
</Chart>
<ChartMobileAttrProvider zoomOut="0" zoomIn="2" allowFullScreen="true" functionalWhenUnactivated="false"/>
<MobileChartCollapsedStyle class="com.fr.form.ui.mobile.MobileChartCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
</MobileChartCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="222" height="301"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="10" y="58" width="222" height="301"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="report6_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report6_c_c" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report6_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="1" left="1" bottom="1" right="1"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__F0218C63DF4CF4BE9B8F39D694DD9EF1">
<IM>
<![CDATA[D,t@Q;qDeu.S5:1O[]AXcMA.<a1e7g?R1r&\%"_;@G^oo`$t-jW;M*Oh?UZ/RBosM^!``ib'L
WOI"G='i-q%Y/gA$OfA;Jg(,&#<!^YW&ljNH5'hf\YGBC0hbcFs9#S;s9Q"@5$)4^Pr9["]A(
iZe(qf0DT;q$\EJHID%a115]A_bV_=Na'7W'Q.;3eGB!"Rmd&E+Ne4$LHmY;=u-C_Ckd;bfG7
X9:Y$Jdme>&nDdh*GnEalQA+p8]AFcU\.(GF0h"9r2G^O]Afkr>l8`KspN",U8Gi>8oEcQFJpr
TP%nHpine*172cO/0/H4$N69mi`/(/=u(-J_HF9;W`=GW!6i[NZ,>5k]AmR+:IlWuu*EkT1-u
@*/">J:r+a:;cYD?<5hMm[eJE"DnFMnM`BE404X7BZ=Z7<FoG@+9StP:TAaVYE>51RgZYQ-t
pCFn;Qm8??no')RTcWG(jH"Ekf+ncCR"639go'b3eIo]A+cn$QG_H:&9KB-7qIb2h]A72a6_H@
B*K?Zp0Tc8c.=*VEk]A":*X'q>==popkdgV9hr.-Mc2=Kn@E:Lq6cutR+Y^`C%'kt[Jk18(l)
1[*`UL*L3W>qf4oUduDhd#b7G2#g?=j!d\BMb#rgt[obEj?frg"=anft6YFPUBdulql$-1Hm
ReNb82cl>,8q#/Ks6NtIY88c#<oKp_8`RW=Y0N_W0s"-rKA/]A"rCk0)@:nW:DQSI"k*B(L"]A
ac!?I(FN<\naua#79s$Ar)ZF_4e@(,12H3T%9?H(>eQmc@+fT&C>*,_Z4BsgUe5.:'s&eMQS
p+[oX?1o3WH(Am<&kQb^(-_&/]A-=Vap3i2hK"6OQ,hOkN]ABB_>X*5LA#2Y5kr$6f4p9_2,e:
Kd`Z4H]AauIb=S,'%9BS]AYcf)^cP3e;LE`9TG]AoC5BId)XJ#mTQkB'u"(TXTq^7RUnCXb';jO
3E\7P0.LGs(f@>jTlW`f<<fNp$NEG%6&P_i'q]A4Lg'4e,OKR3'Jp!T@uDOG34:`<r:bK4+g2
Bj5_VYT2`mVcF6r"7oJ05Hobqn8-u7,L>mFcAFf;KXq["6#Fgl)L&Oe;0JJT`<bs<\]A!\B8R
g!PS]AgW<BTi%qWHZ<hbgjW^(dQ!d6s2.88/FH@>aI"thc[?.X)/hNEY'6Q%@Rs#Vol^C!YHJ
6/2IYcf1b;+@`)T.W(N.inV_7_$/_'mkUo5X/QP-i;a4+_YJ*S/kU90Xj%L^og=T3J=[16I^
7*M%&DakE>YQ6iMfAP10's-=[lEj>;IqJM;m_MfTAe\:J4V6o8gIC,4796;K5`-qU+mo1<H[
G\1ZHfC""g6pC@@adYFI[`ibO##k0[oC3T@=dX%n;U0rY.*05`R3DE0fDI0aZM2TL,5[j_YJ
G*X&:5&U2D=/^'`IB/l;5V$3=3YVGD8@i<fFQi0G-=Omf(PQMO3pUtWaQP8Lj*Rj1?^PZK/?
$He(2)u4B?-s<:KD^4/mELS:C7Wun;LRT2h9$?EB$Tb5(VYjW->j=[^O"3JDZdIFXpcI#IGS
^^>-EUMP=Q@g%^/[YPT=tpOUQG@ijpX56D-SUDh7qOfe"!O_^/U0mpS-'8gbR'Z@f$B+5Fb1
!7)h(7XK>J%e%S2a%Ut(i+)PR4:(OOAYMEr40.9%g6Fl*LW$!)WeBStc5iIXbCE=u=,^sQ\(
^qI/>&ksnh"dG[:SQHmelIW7`io/Tjoej2c')0sXTDa]AACpkU@W6c9?T*rt:.hft#PqgOe9t
=.:`ao7>PoPG($TrU(gDMYX$be($b*@VpK=35>+aIk;*Jpg)eac-r6VKAEf`b9-+1lDBf2Vi
.d]A_+E'"5QeIV0ukm]AYDLuC$oCk:;U6l@ZMrOT77rAc&ZK/!9U&S,W&>YbCKJ'&14TA!4g8E
O6@(9.6#e%I/6[&m@Zo`Y+9AOpa[2-&-mE`Y?17(]A6RUKZ>&+q(u8>rniBe*[XbN(R1jS%7H
#CX/t*^;E?:k@Rm;PU5f=>VF/fVmFD8`hFbS)P;_-U/=5RVBn\>6WjEDRUl0$3,/*0r(S/5@
iLa#1qTRT6Et2nk`7J3ihZ1qHL/bpe<Ep^)-7A:=PBWD=ND6-\=>*I28V;/maIW3KlRb3*O_
qJ[pC+NM#&ug-VKR#5eMJ\Bs[@hpq>/r76hOGMb1lrWJ=CSAAch$W>LmGA.WO0Tr:QL"!^!4
3GO]AocaS(>AL;MiK7=STd5Uaok*iJacNL`(2`L<:3'&L<O^?TFcj<ejn@3F4'.6^Mdth9Wr"
=tY`[:WLn/LU+e]Aio""!3[28T.M_L=>-nYMlg^%Mq&eirYJQAthgU[r9aJ&f\ju(kt[P\erj
Ra6f>J<"BkdH")pKZEJk,3m0fq9YAtAiZ2^u'iXZprbeO6E-oIpMgl:?O.L.+)Ba:h#fd077
GP4hQ<EAMqHB&-i#b.([bB#A+SYM\_?cL3$[jDel0ggd=XXs;2!O^d_Apmsj8Do,RL6Y-l1[
lpjhPTrUKZggJIHHgT"mHO-W^,_2;7HL.10o9&3p=[FX-RS+/qmcqR0b(11#&]A+6@7l!M'F4
IGg\^e6Hn/AcD[>B7E?D^&'s8);oOa_m@-^A(i)ba<X4R6L[&IU&Or4D-maRc4rPloc9Tugh
J>B>nGobkNV5TC7X]A@1+O3M0m`fX`oO)h_\5s1p70Oi%RBA:<LRfi+jH$aO77QG42F)$M.Nk
4a0K@4/##<tC&N]A;j]A!BV-*K-L/FtmsAF[S8)Ln71=`&.@lS8C#KB^aMb\o$/b@f41@Z!=I\
`Orr-a#78/IF%AO.A6aMbFc[H*4_IiSbAQ=Tcq>$P(Rm>5m^'9TC\aUdXd2f<<^:qL'>6d>2
tTPdf)3=m@"\[>UJs"cS;lb8RHDrF5Ve)nl<CIBaAHqs2@JK(<]AnZd2faS9Hr3[rg7,l-aKk
!f+F;?JGNWL;PeX,0/`0jYO'sY/8Yn4O'"M2Ism"&\jC=@76_Tb4_i,8nKk^Od<)*^P)dQS:
TS_dqnc5A]A?ng;?3^pGX73Nr-:W:C+#2%n.l/i:W)u,P/:pL;;F(^YmFY]A'RjEO(7TS8I)jo
X&6Di?!\WK^$I9E(7J0ccX?)*_SBhj"48gRDq^2oi(_JiHnB5EF]A0QLH-7K/3bE<s`?jAAj1
6MKt3&+ILp'7i#:'OcV&<LSMM6R%-qKXdp=`_ElpIH>\MZk>+62dYQ'Wmu*EJU]AVm(jrB*)W
>#&Hh%g)GJ$rp7F*J4Ng/-/\(WqKH,'$0^<nY`7N$//m(HSh>psU4(AGD!<~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[723900,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0">
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand/>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList/>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="0" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="196" height="20"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="597" y="20" width="196" height="20"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="report6_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report6_c" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report6_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="1" left="1" bottom="1" right="1"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__4CC946F8654DF6A300464000BCDCAC7C">
<IM>
<![CDATA[D,u!_;V;sQPEH-a\n[&I<>j@EM?oZ2VI??g;/j`W97.ulj>3^#C$'NI>++BOW"^G^aXGCh='
8Y&SXI>76-3aM1ZhRp=t4-[RG$DoeuZLOh"g-7oBj6+kPfnED]AeeH).JK2`Bk,H9)iPN7L1c
BJq'B^6L]A-^Dra.pp*2_V[OF^%p2$P[IP]AsN2J[*kYH&Fd]AqG>.TNHC&T'7tnWb'2<jG4hk=
ps/EZ,Kg43&!%J"jrK#J(f9j@Ql#KTJpL3o"p%^>riq$pN*>[$0fpD'-k@1jl9)3ipum"&Sp
<b]AdY%N'6dN*RLW&u*UnsL\Ou0.3nR<3/&Ceg7e4j<LIIgn-l`(>of*$Zil#$3mOU4>h@"]A%
mfpNiqP37XZlQ!%RhVq*Q@A57pKNarVikRm=sj%PaPHmmmA*f=OHki]A(4ZMbm\&HT0GS"u0f
t`FU$IbKJ:S9TYA`0=\QVm4s+<Yij$4XGokR@k>K-DuFtI:ER@CO:^l>3uY*c\k1f\C<=@',
bn:MkXGXf*ZCFSE^:!!8+e18f@9-iH3joTO4^Sb60@F;<$0eg'<XD*"AMR-`KD_T=dDp=Y^G
&Bo+"R9l`lL`<29.+[fK=9PjdAIP($@;F)&J7\/=raV_m_a[=9@d=Mo!Re(Z_ZHDqF'VpUKQ
T?UfQ!Cd^@L!ql&.+`9)S2YuGj%CH:;?9M\I13dpV%IM<%:MeYjQq5%=I9dn(";GGj)9(Dha
d+5.C3X"9h?#T=Zr_ss$`p7M=^<3Qg2crscOT'kh[e?Bu70m[5^*=$7=gOBg*N6)]A7gepT8Q
%Y8LCaA3Rk,ttaUbd)'9I:_4%IH"T10SGa3WTMgR,_rK%B$>^.EO^Vq@qorH_hu/n5#eZudd
RS_6/'e)Cg&<EFuLp/!:"M7eOe:o'H9Y'+/ZggEQ2?hN'TcmO8QaM-FHK#//e(?_f$]ARW"Da
hgaYcCeunN0TPRE^aMIe\5>A2NP#\hn)NMr(du^6!sF3TFl'u9sZ@^:);j-&SNk26)(uoPG`
RD(=?jJ89ahl;tch:qE.=5@p7g!8=*j27bL[WB,*aN/%uNn)F45&=L'6Fdq4l`fbX@uq.Rj)
MS=*N"MMKfUbL%O**e9&e@huo%@fo'l$u%<EL?@?9)HX9cEXkDHAQsS6X*1S[lFlQ'3N/]AoS
CO\@]Ag>bno[AICDOK`9C*tF-DbIR6WUh.Vmi_hXl(P(fek-q7kip1;^e3h::D(P3h4c2k]A&L
ZIN..e<U=RGdG.#O^cQO':6P1iK5*Ti$0uNEhcY"1BuBd/eoa-]A8:Nc9,^84&VsM0pTb)s<n
:mjF?:M1@94/ab%I7WgIql8\4bY=D9R%\Tb3IJHOdCk]A+^oKT#C/.2ce3f9SYjl&A0C@!/Ap
WXR>7kE'2*RfefpW3-C@>43U@9DTcrQGVj'41)*6c6KN%R]AqXWZ#!t1/&!cSD(GJra+Wlk^N
UG@<nOa;Q)3[,fpAB6.VkP.?D5tQ7`<F8n(qF4r(Hjk#3cJ&a[*Y^KeA1,IYOSKLkLV6r>PB
j4>-8c*$TStNBGEn;&@WrO-%3,_dEnk:ojQdi1NQRF_D#L)OXRqfPk30D+7pq\B%be>X$M&5
/@;48$.NGNF[\\Bf[[a3$3O&U=(%d*%@E"tX'=h_^^Re>`@`?iuqWS>aPi>KPs)(=qX/b4F:
S4T\+1n/!]A#lLK]AuZAKMXsoYMlE&/o=A;:$ri#ahIO<FHg?`e0JWGsrU<p!-NsDC3-mIFfI5
SroQISSE6/pIG_4oo+O]A(q.c^SNp;eG`Duj$c?$ig[Zp>n:#Y")mINV^e3e0J3%\6&)\dE:b
V,NTR@'q#qX^?*_2@2@rAs\C`&0NThJY1T5)LnFF*k&dV<':Wgm^b'W"]Afu.*'O1XJ6\?/+<
iSu#IS+-R9E5b*+39`VB7c(cJX8EV-lf*Z3opuK/RAf"u5`hcrc>.Eo+/IZaX*a3[H`L.u2K
9`\,iLTVOc=)U-9N'@#%W$8`go%aDq^$tKuR7&\-\^PT43p<Qkp\)Rk$9J^:-:8CW8\="nQQ
(6(DD2Y5!/SSPWI890[L^75o(LLh/O4d*lGjXmmM*l/Z[(\oEaWYdjdY+#Bn*HEEVaFj5N0B
\0Z,qc92TEkOT:9`b[:fLpN=`YYiW!^l<&2G5_$nO:^+05>'OpPK]A[7VY$qp=9%Y[Kr/6c/>
m_8OW]A"!F#HbYVR2%iVtl#6']Aad(aSbX9ss=WA3.eMhca,g5Csqb1VV[)Wof(8n\moc^-Tj+
.)5[9BZG5k'J',?Ne[rr&!9QiN;nD.\F'UEj8,lV."uh5c_%]A*<-7]AJOtt$!\f8ZW"<lOi-,
.*O/[O2"/rVQi`Ikj)N&5V[XorQ,Eb"6,@DqftmgW4A/bYXsZm^:+mL'cah1"1^=2d>X+^gj
dNN-6i7K+7oRIYhH'?@3IWbh>nA3mr:X/Vp6'KH5q3Eo+)&OVJ[#!,Sg)2@'W9^8)uor:Ksa
%W[V!iN)L#3HhdG/l=.))h[q9d$h_\LVD/,:'e(H=.D?$KLE8hV1U_]AOH'4^ZjCU.NYSnTm$
U"p'RpKbXq.d,FlmNG^5AF4n;$NbZ^^tKC2@$T_[B^_f$G6h*s^L-CciJ(2FS<Gj%LOGop!"
AB/oLHdHe4R&kN2<N--YFbqJsFEfIH.*d5aSe>*ung[j'f(2/!W-':LJTM4;s)p>UU>BJ5KD
hq)J+D[.:g<%"0:4\K9(K(LG;UE&<Fh?oJL%G?.p+fTD`4P]AnmrneZWtQQQM+FOSD8"o8Z9c
p:*<@#M#j]A0Lbe+R&^d_d\qSff-,*pPV7/BA\7%RhbN9h$R*Vq;/aYH.jRuFGFt.>U3(9mT@
*orCUpc`58iDE'!G#aV;+GJ8!\edm`g?-9_o!%MV1RM)!i>9$<i`$^Ij&e&pp,\t*`<?>fSt
q@rR!dhAgq;clIIgKZ96UHC_)!c@/@JEk^3$YoS-ntO:c(^oi/]AA(^TX;haMq$fINT!Gh`Hu
QbTFuEE_5u!ROd_Y95QI/Y,KeBZj,J^rc*h[Oh>HE@)^F+;Ta'ih#7*fsBBBU/C.;/@+GLMJ
^<03p]Ad$`Zq[bH:qZ$?'.7A%b/5..0i.$&YMRc.]A7^1QrO^n6RICF!b1[@l@_B'@X#fCTSZP
1k2)m;5n3h+@S9PWFoRqg'cTLYckL.%%V"M?DiR<mC-1"(8k":#?GY4S>@Q98\Q'R.M-O:nd
p?)dt5Z4Fo]AQZ]A>5UY$`sKdWsg.*>g*52)=a_1A''&6!ED2,+_DIm*J/0XojO:BT/>TYmQ^<
\7TUXqb/@Z"8''%SAnTS""R2Aj1I[jb7Blk!E'sM+o2CTd$;C7pce~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[723900,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0">
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand/>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList/>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="0" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="220" height="20"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="124" y="20" width="220" height="20"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<Listener event="afterinit">
<JavaScript class="com.fr.js.JavaScriptImpl">
<Parameters/>
<Content>
<![CDATA[setTimeout(function(){
	$("div[widgetname=REPORT3_C_C_C]A").find(".reportContent")[0]A.style.overflow="hidden"
},100);]]></Content>
</JavaScript>
</Listener>
<WidgetName name="report3_c_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report3_c_c_c" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report3_c_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="1" left="1" bottom="1" right="1"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__9BB2985780BA65AD1EEF95B35E198624">
<IM>
<![CDATA[>uh82;Y_49[sY/7bUZq=@@3Qs8oi-LV(>=md7MS^PXTAnS8cRr9UuE+)&5l/=h[R7^`!?pnq
i0:b?2pNUn`L.>DnjPi_,Lk$6/0AbY.,HkFR&#kI]AX?q^n/Pl&_RoAh0ubJj:G7[(gN-#R$G
FhIDP)(9^60*;i)F'-FTbG?@>&E\t*Wr/aokM@/1Q)>VXV5?7?@CRY:_9kYZtV62@DA@-oVn
GRWr1O07LG>t_:cTeT\?R"$)(`KQe",<tI5s,8.2g0Vm&nlQ/"ObNNZk"td@nJ<6_`[C:7<7
kLIj[#qE>?Am=Y*U_]AF0GA=<L2r.4c.@%[i1_1VqBMllF16kJAAK*eWdfE?033,X9D.Bq*<Z
r,bYAlfurr/EL:nN.jI6+6D"nc(k\U5[UTLSlh4'ES]ABhN8BqUDL55aftgDA=bp_hH>DLcO]A
"jFfduJC&Zh_tcsY.ENh9raC&#DkA*LMY=j>7_orPP/22?HXT"K>HG`qZ`S3i+tCQmM8">,2
"2:E]AMm]Aa3]AR+qq5Y`1VMcKuC^dFtBm2qVdi%jS35Qak1pdYjW_]AeQ;a3GTk:Uh5QadLrGVT
uC@Z1)c`;^U>l@@P+@(J\/^$W9[#bE-q;u=YR!29V_;q_mOsI-q;`RjKTKM*l^!8'Vd]A;fbS
Y1<l7a9Or@2'UhWVK+&nh*qR<=%'kYXb4@cY`G`d$$@[+XA%Y)N:P=-(:q7HNfL_r<MF))&`
A>f;8"XS2Yp>WSQa`0%oR)Y3P]A1+n2h*ptpkA"2)0m/jQ*d2a5h6#C^d.m;2i_K]Ae@+KH_[9
l?]AM"NP"J&t`;6`:MRd>Y&+DR?,S-;fh$O51V2<,SCjDW>(f:^9XI]AJP#k3lZi-gASN44,n6
5EATFt>dL;Q.[]ABs]AC7prlR8`3+^UXTr;J=J6*XI:)SL+1I>h.&(p&16o0%=6-["RV/l9Pfe
@p7GDQFV$nTCK=b%iA$UF,["VC$RP"R91F.2DMI0O]AYHnq6)3![M(0C%:Z+d15^Tj,Ze?MdE
;2?YZV#c)&nQS&091p(!]AagAY`/HFd!4e>I2b[`&d7Ce@@51.RFDiRJNZ_PY>Elc%pnIR3mJ
ohj\6Zpa`:]Ao,+TpIKMubQs8n'DF;'2nUZ#-VLem0r-i6[SskC3]A(6pgYa=s8?KKdk>riI81
&]A8;<Z*bpYB81Z2HP\l!UQQjcXC8VIsX8'qBL%ZD;$4=-#qjI38I0\b6OH_YtNRdDm`CQ+ca
kbXn6&,&BH]A#d1r,@ndk(Opf9:<Uk<'U/0U+]AHMt5L1f8Up*#eTj3?^45_g^phN2'.hU:`dW
BkX6?@gNfa6$DKP7(\\:T(Z05Y0,BFOT?^*aSrUs4fn^N7Zc("DhnIqLY3h8_/Ta6,XanNq^
A-O4XL^kE!PJAHdN/Q2h,DO.JKLmW?DsV%j".?1`8:pR308LReIJH@M-\MJ0I%N6L&-8K:KF
dpGj[.i`3K4E>=n2%V%Ua`m65I`Fgr*s%$IHRCg_O/R1UU7?["d,9TZlOJIC:tYl:1IUW)CD
9Kf0B9.p+E4&V;U_V0N:)uE!1.@[dZ->M4q]A?rFnBmFF-<3L<ZgN0d]ASc!QtNa2/CEk@6A&4
%c$)HH]AYPXa,1oi2<GNW.C[L<T1eRl#'=dp(ADRp9kLqH%bO;SIBb!*[SXMRTSCYfA>nUL)^
Kt!bel+YJS=5;1=T\:Z9ZK0U[8sU;T<TrJ@%[JST)4>(filO!UZJ1-E1AibDi1:i3a5%q`@Z
Sj9a7>;,(85(EgQ8gH@(=ipZ4tC5QDU9klY,)kP]ArNpd?Mm^XeqI@.SQHi=\_pLM5FXK25:G
U450B_q08=bWb@sEQ]A+Y'Q+--Cqf-l?B;grndZHqQ0+[eg,6(2I=dUB3#9!0K"9l[J=%-oCa
aomADT5;B0/LC1[1&LfrI(4JltH3Gs#%A!Kb"<$hEQq/sQU%QU3?%RF:#F29Q&0N)JKFoL0^
4-`mBKXbcg3\B-^QYio`8.7Pu@I8pCT#/GHo2jlX!K0(qI3rkd.>i[7P.I+:iSOhRB&Q&C#G
@1XI2r"C82?P*#eiOnM3lB1l3J)B"_S"&&0..BN,m$;6*HBh"-i!qG@uD4#Zs!sc#!EKdZAD
6/`1JJ\[&@B*.A.4<@0<"/1m.hE]AmX_Is*e`-L5Q&BG7cu,R)>JbX:o_\D=#>GT#Os#?4&73
+LCDj$UELchmL7<0&Non0$5<#"6_fL?]Ah!7lE6rd!^_rTPWOI$mr_r[SnBNGY2$PUc0+LP)Q
Ta&jgnTHS5'Meg'#W26\sP!W9gXY`>Y;TS*.DGRDlaAVe4/$Qda[0/d*.U^o8*jejF:`oo8a
qfWmsY56RDPi&J8lY,ZT,Le/g:U=7$e;Fbl4JugS+N&!'XNf-W^:%9gR4^!>_db8H=ESU'Vh
!b.n&F+&Xno1S3qFm4EKnGg3T4_He+cHoq[IF+%4T$>\T\)\^`"i/B5ZWDJbq9K"I=`<@#Q6
NoOP;3raeA"c=oP"TF#hh#f$CHY-e[t*1VS5T9e'tqNF&.c43en5,g%?:Rt%.G_t55t8^&S=
.Di3!%4s"sb#O8nEbc:p&Kp=dG'o+g$R(EUjI7DSF_D)Z*,SP_a14bM)&3sh-bK&=CFIeYoM
/65a5#SI1tss)Eu:!&b5U#[2sg.CGHO4+PT4g0a$/E)=DV;1WLVFMfg?g4s"r&tY\3R2f_>#
js"MJj.TQ?B:mQ%9,'+8%I3q/YFXgfleQuVomg%`-#MEZ(B%W!O[^'#.pZoN-5p2Q2R#,W5!
eHHJ:h="J=;9fpBViQ)^M4>60?BKhF+<%R~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[1143000,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[457200,3139440,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0">
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="1" r="0" s="0">
<O>
<![CDATA[渠道产品日毛利分析]]></O>
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style imageLayout="1">
<FRFont name="SimSun" style="0" size="120">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[m?DBgP%PWPhr`(eba#<,VTt()/=CR9-IYsU:SlTRR)]AVVR45'_+:;Gu5W_i?=XpXeg;1uac_
@:)A<phL:fE53&>?h,M%C^4=P)*$IG9N_fDFran)sNFn,%CekPf,^o(=[n0Jrh1^sL9RD%?W
jK`Q^qs87/2b\=b<Er[o?oQ&^_4/$&d0D[tg%(JB&)-qPBi=Mb@rk[LL*32[o=nKWjk.EH$U
t]Asc;cS4\iU-%*bDmD*D-+D2)H,O9b]A?(t13*;UZ_$oGl5l!T.YrR.;u8M+'S7#R/n_-S/s7
KfrKs"Bl:0[BiB$eg.Prn]A>90Z/>Xk>P+6\Qoi1^*Cb-A+'8X=%aZk/UKCaS[f9t2:1R2'hZ
@ZDf%o$9OgARt(8f1Uu>X>"]A.&>S\u3ZoZWb!I$8`X3%hbJgo`$dti/b:J%EXUECFj^XI36t
TEL-?I=<_CKH3!Q\M@cRj;+fL,lP0g,g5R'9(?V!_=-Kr#b,cZ.5k,M*Y_@=E%Y"WI=,boX?
1[N'Xj6(5$:NH7c!]AR_Ru$b4UOM<GT$%`WNMBul8(G(_5a/MRXfbf7cE4j4/^+ONf,T"r),@
ESJp$\[>/F_@_u[!(H6M>dT2+*<*W!U9o1ZEaZ.@7)Qm?&YI'`/<'<CclcIE?T(h"`_,X88<
EIdj^eAcu7B(l#rq-g6tt0KW,Q?d#Ypk^uZ]Ar)".?f7ep)A6_[3C)iZ`Q1Ze:#Ml+s>2M%n5
*@D@%hRJGj1slfacX9D'b+4\^CN)gNB4<L5Pp!ju>^I^+C<:P:)#?6dC^0bfp+8s1Z=h`aJ1
F^KK+1_&AP[?J)SmAl4Hq!kYh[5T(PQO@F:#B7O6,Qh05<8M.*#"F'HZAm4-?B<NJ#i,]A!i=
Fnshg0?.b9:.=L2WA&UZt>S<Hd=A;<$@#BYT@.I9j]A"Mh)L>QgRE^F.U^\A3fA.''YLR]A1uC
eKd*Cuh*Jc21E-%LqHFJerJ,rl``+G$d[4mQ^k3#UBkA3IQcTAj%*NDGLRMYH:fcoZ1c,[<`
(0%2Z'd:H(;>nTEe]A#"Xn3F^hhgjr_p\j5G>/""tiTSkO%g&7*W(C?l#IpmpC6%cFrJFXl,9
_X\<Q'LOM72t)4q0e*ZL/+rdalHs@K5f"*=':@:^N5ERCNcI+H2tS6;IH?tc,Sl5%lFL(qMi
f#c]A+M[B<CD"&91;p.jG]A7&bUr*b=/P8*MS>/"geM;WdCnBhnhbnj(j2i/`_U<FHhW'ZU&9k
Nmrle2*R%KGnjVEYI`,au@H]AZfLfZ%6g;$g7,aH;hq5QE?L7'hU?ctEa)t/gUYP^B)n#R$4&
=(+pb,DhS<g9d-j`C%e#&eP#(.+/)?1VN4N(aMLI0lLg`PCe"'`h@8[o)7(j7Q@^6^GhJ3MS
r,%NJ/<I9]AXUEUn[DGD4dZK1_-iQ]A_,\]A;:Ek]A+kp0FPV&9)7PZ=BP(.o?o6dhR8HW.8u6%:
LaH&)bMdK`(u0d\^M2Gl'P(=l<1WN2OK"iRY1I;6E@V*6erDD&V1'&&]A!bGBEj!pl,g$B7BM
&jj=7aEAG-fDim5>DlG1(=#3?Lj2^eQg8\71]AXO`KDZTo=Id/Da-s/Y]AGQ5TjRP#.SA`q*_\
ACBubsmScMU`p529FaDRqCXp+sEdNN1?FBs,K&nK8`en"Ng^*@r&'qOKP%rulP*BGBe4@!+8
ghJ$(O]AD]AAfORq]AB.MoNXL;Qj\lt%i?%//Z7a!3jQX2=m1MdV,j26IEP&Xia76nuA+/QVZ`r
Vf4`BN.?E_Ti`cXjpra.h6S8M'fWLC@YUOR!;c5GLOgff,>-+()s8d2Z\WX1f.&aL7S1J4V8
7Fb?+[0+a.P<rp=LcY7McY\9bX[u%4Y*N8*8pE@.7N2@)X#"i.rtfUE*<LS"$_1?,drq%CX`
HM\nne3\c[#Sq?De*SAjRo!67@LR."jo8KL.)?67@LR."jo8KL.)?67@Nd([1b#Te7kONk]A2
K;SuREFnu!?=Xn&bC[W<MK`EbZBG"GG^G#H<6l'C;DI1(RS+LaqFh>2$s.B;k~
]]></IM>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="0" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="267" height="20"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="687" y="43" width="267" height="20"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<Listener event="afterinit">
<JavaScript class="com.fr.js.JavaScriptImpl">
<Parameters/>
<Content>
<![CDATA[setTimeout(function(){
	$("div[widgetname=REPORT3]A").find(".reportContent")[0]A.style.overflow="hidden"
},100);]]></Content>
</JavaScript>
</Listener>
<WidgetName name="report3"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report3" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report3"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="1" left="1" bottom="1" right="1"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__9BB2985780BA65AD1EEF95B35E198624">
<IM>
<![CDATA[>uh82;Y_49[sY/7bUZq=@@3Qs8oi-LV(>=md7MS^PXTAnS8cRr9UuE+)&5l/=h[R7^`!?pnq
i0:b?2pNUn`L.>DnjPi_,Lk$6/0AbY.,HkFR&#kI]AX?q^n/Pl&_RoAh0ubJj:G7[(gN-#R$G
FhIDP)(9^60*;i)F'-FTbG?@>&E\t*Wr/aokM@/1Q)>VXV5?7?@CRY:_9kYZtV62@DA@-oVn
GRWr1O07LG>t_:cTeT\?R"$)(`KQe",<tI5s,8.2g0Vm&nlQ/"ObNNZk"td@nJ<6_`[C:7<7
kLIj[#qE>?Am=Y*U_]AF0GA=<L2r.4c.@%[i1_1VqBMllF16kJAAK*eWdfE?033,X9D.Bq*<Z
r,bYAlfurr/EL:nN.jI6+6D"nc(k\U5[UTLSlh4'ES]ABhN8BqUDL55aftgDA=bp_hH>DLcO]A
"jFfduJC&Zh_tcsY.ENh9raC&#DkA*LMY=j>7_orPP/22?HXT"K>HG`qZ`S3i+tCQmM8">,2
"2:E]AMm]Aa3]AR+qq5Y`1VMcKuC^dFtBm2qVdi%jS35Qak1pdYjW_]AeQ;a3GTk:Uh5QadLrGVT
uC@Z1)c`;^U>l@@P+@(J\/^$W9[#bE-q;u=YR!29V_;q_mOsI-q;`RjKTKM*l^!8'Vd]A;fbS
Y1<l7a9Or@2'UhWVK+&nh*qR<=%'kYXb4@cY`G`d$$@[+XA%Y)N:P=-(:q7HNfL_r<MF))&`
A>f;8"XS2Yp>WSQa`0%oR)Y3P]A1+n2h*ptpkA"2)0m/jQ*d2a5h6#C^d.m;2i_K]Ae@+KH_[9
l?]AM"NP"J&t`;6`:MRd>Y&+DR?,S-;fh$O51V2<,SCjDW>(f:^9XI]AJP#k3lZi-gASN44,n6
5EATFt>dL;Q.[]ABs]AC7prlR8`3+^UXTr;J=J6*XI:)SL+1I>h.&(p&16o0%=6-["RV/l9Pfe
@p7GDQFV$nTCK=b%iA$UF,["VC$RP"R91F.2DMI0O]AYHnq6)3![M(0C%:Z+d15^Tj,Ze?MdE
;2?YZV#c)&nQS&091p(!]AagAY`/HFd!4e>I2b[`&d7Ce@@51.RFDiRJNZ_PY>Elc%pnIR3mJ
ohj\6Zpa`:]Ao,+TpIKMubQs8n'DF;'2nUZ#-VLem0r-i6[SskC3]A(6pgYa=s8?KKdk>riI81
&]A8;<Z*bpYB81Z2HP\l!UQQjcXC8VIsX8'qBL%ZD;$4=-#qjI38I0\b6OH_YtNRdDm`CQ+ca
kbXn6&,&BH]A#d1r,@ndk(Opf9:<Uk<'U/0U+]AHMt5L1f8Up*#eTj3?^45_g^phN2'.hU:`dW
BkX6?@gNfa6$DKP7(\\:T(Z05Y0,BFOT?^*aSrUs4fn^N7Zc("DhnIqLY3h8_/Ta6,XanNq^
A-O4XL^kE!PJAHdN/Q2h,DO.JKLmW?DsV%j".?1`8:pR308LReIJH@M-\MJ0I%N6L&-8K:KF
dpGj[.i`3K4E>=n2%V%Ua`m65I`Fgr*s%$IHRCg_O/R1UU7?["d,9TZlOJIC:tYl:1IUW)CD
9Kf0B9.p+E4&V;U_V0N:)uE!1.@[dZ->M4q]A?rFnBmFF-<3L<ZgN0d]ASc!QtNa2/CEk@6A&4
%c$)HH]AYPXa,1oi2<GNW.C[L<T1eRl#'=dp(ADRp9kLqH%bO;SIBb!*[SXMRTSCYfA>nUL)^
Kt!bel+YJS=5;1=T\:Z9ZK0U[8sU;T<TrJ@%[JST)4>(filO!UZJ1-E1AibDi1:i3a5%q`@Z
Sj9a7>;,(85(EgQ8gH@(=ipZ4tC5QDU9klY,)kP]ArNpd?Mm^XeqI@.SQHi=\_pLM5FXK25:G
U450B_q08=bWb@sEQ]A+Y'Q+--Cqf-l?B;grndZHqQ0+[eg,6(2I=dUB3#9!0K"9l[J=%-oCa
aomADT5;B0/LC1[1&LfrI(4JltH3Gs#%A!Kb"<$hEQq/sQU%QU3?%RF:#F29Q&0N)JKFoL0^
4-`mBKXbcg3\B-^QYio`8.7Pu@I8pCT#/GHo2jlX!K0(qI3rkd.>i[7P.I+:iSOhRB&Q&C#G
@1XI2r"C82?P*#eiOnM3lB1l3J)B"_S"&&0..BN,m$;6*HBh"-i!qG@uD4#Zs!sc#!EKdZAD
6/`1JJ\[&@B*.A.4<@0<"/1m.hE]AmX_Is*e`-L5Q&BG7cu,R)>JbX:o_\D=#>GT#Os#?4&73
+LCDj$UELchmL7<0&Non0$5<#"6_fL?]Ah!7lE6rd!^_rTPWOI$mr_r[SnBNGY2$PUc0+LP)Q
Ta&jgnTHS5'Meg'#W26\sP!W9gXY`>Y;TS*.DGRDlaAVe4/$Qda[0/d*.U^o8*jejF:`oo8a
qfWmsY56RDPi&J8lY,ZT,Le/g:U=7$e;Fbl4JugS+N&!'XNf-W^:%9gR4^!>_db8H=ESU'Vh
!b.n&F+&Xno1S3qFm4EKnGg3T4_He+cHoq[IF+%4T$>\T\)\^`"i/B5ZWDJbq9K"I=`<@#Q6
NoOP;3raeA"c=oP"TF#hh#f$CHY-e[t*1VS5T9e'tqNF&.c43en5,g%?:Rt%.G_t55t8^&S=
.Di3!%4s"sb#O8nEbc:p&Kp=dG'o+g$R(EUjI7DSF_D)Z*,SP_a14bM)&3sh-bK&=CFIeYoM
/65a5#SI1tss)Eu:!&b5U#[2sg.CGHO4+PT4g0a$/E)=DV;1WLVFMfg?g4s"r&tY\3R2f_>#
js"MJj.TQ?B:mQ%9,'+8%I3q/YFXgfleQuVomg%`-#MEZ(B%W!O[^'#.pZoN-5p2Q2R#,W5!
eHHJ:h="J=;9fpBViQ)^M4>60?BKhF+<%R~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[723900,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[304800,3931920,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0">
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="1" r="0" s="0">
<O t="XMLable" class="com.fr.base.Formula">
<Attributes>
<![CDATA[= MONTH(DATEDELTA(TODAY(),-1))+ "月线上销售排行榜"]]></Attributes>
</O>
<PrivilegeControl/>
<CellGUIAttr adjustmode="0" showAsDefault="true"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style imageLayout="1">
<FRFont name="SimSun" style="0" size="120">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[mF)"jRs,hPn7Q7[W\7jfXUE8%;Of22<=tS!]AlY`JWc=tW^0GlX7V/W+*[J\SN_<Yl17N?YmT
`t3V%Q]A^M[8?T^.$WnnHb^ZI>KP<4JWVI-;253re(0TkGRM=I!L.sn'C1qk$5M:j6HPn1B7E
XYuf!Q!:Z9r!&u5EH.tAYj1tBi!/rb#Hnhn);)^.Fq\\ti=7]AKPKDSi$4R.3NROFmO\T<g%l
G"$,mRZi_"I%^\pe6d!lHAABHp**ENX$*njXIc9*D#_fGkik7d;`V'"1j'J[.q]A`OJHk>3k-
!k=^W+AY(&n\f4RXg?MnYrEGs+H)B>.'ji,!drN3;@/C2-nlp&>F@90trYl867P=Jl;ZaNT&
b:QAP`OG42:Jj&Wl`kl>]A3WhjgI+4aTK"e3>8B6>]AY"".<#"O#@hrrHL"1s6SIMK-1`$kIdM
gb@oWhB-BhhqsLoZ1r80hAk1tSs<X)A>X:;2H_'oHjnrsqS_GYh&+8*mrTqROtTO!nr#'<*X
%>mb?.X0h:TE(USp$0kIs^%#V[Z1j_>*J069Yk\^m=)=k3*bq_i\n%[3pZ1:iL<O_?S>+Ob.
J*)(Z7ggEpnt?=?6tUj^#JPJ)?5g>1BR7K?+P^uX:NoMO:;+63c&ZlK[fQKcIM8+0L&EA:eX
C]AbV\?D@B_Pu#4<%)&2#fo-1kn0D!Xl;RP.K#XXBCSPseJ.Soe%H%/!A7&O(7q,<VD<>#87f
KoIA1A,B-Bk)';b-EpUqi5G&$XZ+AS?'qC$!d"('$_-<#<$1`$Zb>!b9AAjb-#[uI9J?pSNF
P$*9LtGS^!T`Wp34q[m+00J6FZ^'LM"jkJu)dJ'C7GIr*JjNF^?D7Gk;E.q<[U.QjCmJ$-]Aq
C4EiOiDoj&:G+[od-a=3=-VD;),aHAm6VAf]A,p[fmGimqDA$>c,LgOsIOM9foiT'RK3Qo&]A'
akfELKCac!mkIg%56bAl363c6?TK>6tq=A3_.rT:UcD5..UZ694eii5.n'@a>_Z4RQot9C#H
.62^L[/L\2gJD*_1bR5]A:sqRa$jEi^kOma\4VJTq8'^NX1'(#`1Y3ng5b=l(\kY0dAdRu.[$
R9FZ.EmCo%B+"3)Jr<uMip8D+^2$NC@qh&OA5PMOe-T,'G/SJ?F),s+KVnJrMi&:(&K((One
J_\HZa"b+)o`\jCcm_"lNrj4$nY8?t9hsor5L4?74!]AQ@6\n>1;,387cZ9Y+*7c_jCPIbYKL
_d/U?K/0&!11>Cf!)jOM)_LT:8klZ;!K;+X_f`M3b&$GT!T:H"6p=95H*)u*"MEQ))TuGXW\
aPAQPbJkg-q,RW;2S89U(jFP74Ci+MGf\5'W(h.MAR2Aqf`"VU?i9\LpSTR.+#+"&++"dGkM
FAPQQjsU5T'5U3"U:^Fo0@bp;$lp@;4(qk^AUrr<~
]]></IM>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="0" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="207" height="20"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="10" y="38" width="207" height="20"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="report2"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report2" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report2"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="1" left="1" bottom="1" right="1"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[2590800,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[1310640,14752320,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0">
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="1" r="0" s="0">
<O>
<![CDATA[2024年榴芒一刻线上销售驾驶舱]]></O>
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style horizontal_alignment="0" imageLayout="1">
<FRFont name="微软雅黑" style="0" size="160">
<foreground>
<FineColor color="-3342337" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[m<E8GP?G@Q<lBTBN.Y$KJq-H0&1JJrL`f,O7$J5o!U8#=Us,b^(*JF,2[>#/#XNbG-t<<(&0
XAj5gTfD;F6%u5QXMPSG25ok+)$KfD#%:/q,t\H.K^]AITG-;YC/XJj9XPI;fS_"Pggc/$g1f
kUpd6q8SrJ%Z!HoHF\A<`Pa(TC[cabFa61cEaOHWi_*1=jDqZkRmDhG@/j=Z-L[9R)ec"&J8
jV]A;4&=2bHre8)HB'JPB^._8Q$abPr8&pJ)`qkceDIh.OQPSD+1X"VXZNuZ5IG"qU[pRe?Vk
1CFG4OKqs7jt(P;?0MC*LfUC9m?"DquFPp)6a.0HtXl>\Pnjb2]A-k,=rF(^chbUO/hl;b<IT
UjcnQCq$rY&,MJXGZ*7@hljeEWg+"+9cp0(S_RMX9en%tU$fUp6."e77t1"5?^5Y%0:*gJg+
f;=$/k\DCKGbJVd03mai(6c`DZip]Af_XI-GG9?$2&`=Es*HV=@pD`G+aiFJ(OBqh$fu2ba33
^Y2OJ"pmL"i1FL7Z/%k;u;Ou"S`;rZF-mMP,An!^&`Mdl[/mEWP]A.8cS=\SBt:/;7(<1%,j\
-d%B8_Rb_fJDf9P2EJ"-Wr2_qVa??>`,f2eqZhnnDuI=4/ahW8(VoR^ne,m1%9`r3+>+[&<a
B%G0X&[(bduk(VQ@._,6,s\$3I/aAO;AilkfWfIkH#B:7[-#ir3V:K[7eK!UQ,0sI>=[W>'.
lj,ITaLX&'ODdL-KPUa#&Yo,iW52Vdm+V"8T*N)n!1e5#!VFAM(GJPkraJei+9SnI]AAVDI^]A
""jX/O=kX9&Mjl-`bPeO6MGBV6Bb#Z*>rn*Wi66'=jkBS3A'qmA[b900Ue_VeQ>dUGiOJ4Kk
CrjuG%Bp7!23YuBBqMNct@jn$'T5S-Y0+'S3f`iHD'tK..^D+hV3<l/t).ABeKTj`PQn&XdT
i4Us`Gm7<V`,2c.rdA=D;NB'n0SU]Ak6B@hB+CN;^r_27qF'VFij^L^NCF1WB_QgEDldOHG+6
@uOX+Ye]AYXPqK#s8)"Z(`2_TY4ldCA)>dH'=:iO`0e^>2R/.)41*j*F3n=2oY4PB@.bb,a-=
-[Psh8IXb2X-QG51S5O;A??JL=rR/Flj%cci4f4)B;G6>T=@bY,!@_odqN0RH-gMo5%-t#E0
Fmoi5i/K(:=PP:JKS1-KuWd73>a$JbLUC(kUm1pSQoYoAV5,-Nb>q,Lp,J.\b-TZGYIoRR0\
_FqIP:FO#NlKPSWQT+g2PKkCSK:G(ef-ueGeX(B`n^PlDpp$lQ.\N#`J0@",(d:CA]ABLBu-2
0VsMUWH]AkYW:C/(ksf/h8$c@k?N(_CP5rHS>4i9i6`aN2Z\mY-`=eQo>6Upj4@cAN\a6o\f[
)/$3sX2E((4W3[HY;-:ob!jEP^c4M[-IX83(9"BD:%$DKBQ"a)[>=W]A>u0ph%N)gXNm^e[Ep
Z[>5q;`G\[2972FUO'-Q5]A(=eUNq;1`goSM"tcIa]AM!ESo(*OQbJs(ZmW!<[VKM)00(jqP.<
'h<NBl]AKS_-9c/,Z1RC45&2k7Bu,e>*.p^<<'4;R70'0FLJ-.gWKq?cb,dSoPqugK;#EFDS9
'FmPpVpH1YhD/FJ]A$2o3Ob[btdF>RucD/+g1D\oI7P3E3*Qs)lgh02[lh]AsM5I<39:LZ@*_`
PjAd%&ED:A,8R(`4P45GY@HsruiZ)c)bFQWpecuYBsE!CVa>i@MIVM%n/V/eZVDDJ(#*a3Mg
Qlka*lB(=gM9eG<tU"[CBC2^-t*-J^r^Y]A_(+Sf4kH*jt+)OVT?8J/216?3MgbL\^pQN&m8E
(rK>bAO##W3l]A]Am8Ack;!&l,P5nmU+5t@lFb-@ab%qK/VKjbEf@9d.7"+A7]A^dL_9UCX^(r7
,IL3&'S2+E!WM_lb]A^Dp6.X]A$_]AOrSfJsMAL-N+i2*>cqD<25d\\aZM&f7H9a5k?Mdsh/em3
57><4[LnCnnM;laq%X53^I&pTuF%1TPSlX.2%BE::=*M<XTmfgI2GDZB]An+q=<AJ.I#KJSI-
h*CWrLZ8;s(a_fKiRl%bOf,`=N\*([nl@iG"uRrmQ8C,YhIsL)8S0?rpmcthRY'M7D!BQ58Y
%Xfh(#^G>'>!g\IU%it8B\Nej]Ah4lm/ej4"H'milq#+]A)ndToQ%bR>XH_HOqB'En,O4rKPFZ
Ab4%TBe0W"Bmacl=>Z*V:>m`m_662F&!Bpa9q`F\pabD[DF_Vfh:bn=j-:Q!2EeJVUS>6n5_
L'o$kaV9^!F]ABZsHtHWtL/sPR:jLIn?:EndaDWC&jGB'DP?\=;Rf^5-s>=S6**5e1Fb_V+`<
EVrj<2Xl_^"O;23OSF4/s5W,U;(P+08TZI']AWkS4\]Ap=?U`lbNnq%%h/iRpo-P!S3$::?oOD
\#5'$)sQq,Z<d6!_'??g.ja9"h\/H`)2e_Y08?7KYH>.pG"!+.-K7VRm$8%02i(VmNBnuf,F
BS5qH7HFp7+KFSlj)LEV'[AWU+sEk&$2b^m@ZjLpgi0W]A]A^icC!jjNs+]A<mT:)>8S'f>pn+6
hbhdcf:RNd<>CQ"29VU0(HjRBp=!GcB/U=Ba6rnDnM6I[/.1I'hUROmX&"F59iJd]A&;VC%<"
e4DkR\(t:(b'W7kea.fSX]AfY5oBu%??rcpP2+I6EXDheTBH<>]AER*8nZm>'TO?*h9;^Kh]A@t
l[coM:Qo>W&En+JFY<jSe5LBQX:*ECJqX]A!]Ajt@qoO,1HG\e3?(F:SuNeOT=h_U=V)]AdYg_n
moH7*ANOu[T\541/cZ;EP6N8B!t/fBZH-W;$_:F%VL62Q=T?c)-:gH*m!R<&0p.]AOJ$;XD,f
irT(Y;B\-Cn/NAUa[_^O#u29tqYm9PHuR[iF3@.1\[oMj,\mEYW<'s%OS,kl>=3;Ui"cP;5/
),)+uR#oZ+(burs<TmHU`.V44M-*,*c"PG&`L&?]A,9(9*bS%M=)lFg;gm"(UY<caA1TmQM#"
%)!F5GNX>EuW]AH!8&m70\>(JJ7uJp!*csnGCCi/m##sB\0uW*Y!W73F.9<Y??%^AebZY%`Nc
m8GiQ]ARBT[ld'Z7uYPjiBDXgRqSt:0Iik4?r]A(OW^h[C%N`(Bdd-2>$mNaFQK`u)M!3ZK*Sr
;,*O7n#).*?M"`5F!-LDpT2M+*c(Jq9:HX*&X5XCeJ[RE(L_,:j9fT7Hj%rHA"=Hfpt6J;<[
@P!D26h24['lP."rYSI/KIT?]AMp.OqCX"?2&*3JN[B[*a@(Jk+*kq;JJrF7Z>CNn@$s(S2EG
lGsU*>Y9gE`HPo3abE&r,&UfM*+t1M!Sg-<3?!9,q,MYWjFdar(P!bi-A;V9+Q>5dp&"GP2M
)8./R>E_:C@p:1N6oor&O2hT7)quh"=r*!c+QMZMrWm*@U9Vd@l(FGj>D`7oE<j+5:H(nqTG
\P-jh@I*a.2,V.HAY`33K]AP.bn>'MLO;oqrPjX3BY<Ie_MF)fDO5*NI?bu[E8kd/qa"U\;[1
W:Nr8Qo8Q3"JZ0Vm;,V"qA1_!BsR5Se(Lh.GQ9tr\?Q\8KH]A(@O)m`ahVjc$a0SWmp2/NL*H
J\Z88MtLI3)b_)&VV\+B,iQX`.,9sPkW"o:*[eW\%lC1XaKG#bWP)EkLjgIjR_Df"PZ4/Q6a
L/cU9Utaog2/4J/(!LOt_4R[7NF$!EYTat.;j-'Mc:phM6]ATh-#9r32qPu\Jee=4ISKOLX=<
B_j*KV7ZO+i)+o:HjPT+a72_E%crU"7#Nq;<'/\-1W*\E"3[!OV5VMZD-=+JWI6*>OsuIm?0
"T1ul[dUFYqebO#I8T%kE=lDrSK<4V20Foo'M44YEJa;-A<D=eY@`%kLL.4N,5.(pn6k-f9G
o('4edO_:87l]Ae28h9BJ`2cChp`!kr--CJk.u5$9Yrr'l#s\B/@;;kRY6Xjl=RH^%k$*s<I]A
0P2GB\phc\m5gd'Y2h'5_B)WNjY,0^F6iGb;IS_1AROs2K0`(b1fd;nNoCBQV^IGtF)ZHjL;
2Qu`]AO2=DKhE@59T]A>$XQc58:0FEig)l(e8HMTUfI9\=*Y*]A;+NcR5J5<0Z*0,NX5S.-G^"M
A7a'lY?*%gmhH9):n[a<Npp"\+``RgE9&RZ.j$a_EFt:t?W"-GP7H3"!&W@=J-MpkG]A+"r$o
lD%aeM.0_L@Au(P1luNmMm,S.Br9RUSfQkau9sZi"6;4\a/BMb5MTV"PU9$W_dX\o_cDfMdn
3iE?m'1R_@JT=G$\]AgZ75W9`7F.=h19%B.ij(Ah"^-Jh)Wk1i4q?OmDp!7#KaIJZo:1/<>6R
\H5\@Ye/GQsA_'N9o=R)'prms<FOf\m-IUA[n$VS2m6M1\UeejOr6JmtJgJ&M,8^**QC4!UX
,:VlJcq90B`*5ekb\lPr-C*_.c?t)rfK=m*8Li%cMK-nbB`Q@&^ePmA30!0]A]A4e+(kunq%>b
@Ii5hQD/6$m/O\daqV$$,Wp87]AS*+5:b3q1*H2p5lV(;5Dm=@k>+3nAZROQGqL=Ms9`pd?"0
FL?<Op>`X:XLF</rGiqeX!TV'ik:ObshF[X3!k49!%lL>5;+45@J<&c-9GtUM(EaGf1%^j/L
!g(Ll.]AWR4PFNG-+U_Y)WTjo7(>kVpnjb+nBX&E.V-t[Iopj++EW;=X3RF0Y??J.\kHZCo*2
T)]A2m!^,!HffW_DJml^6d8#FDMlbeO4)>TeHGeqCdcUor:AW[^Gt;o+`$$[-JaXM#gp[Chq@
;9uCq/5VD6R`<9rh0eb)a0T$Xa8tDq6r6e2ECIq;22%Q."&7Q,Y/)O7FdQlO;MBcbKe,I3JK
]AHtDf$&fGY6"N%l0Q3KIq?'Wc0:!:f7aSYnkk9/G?'-hl8>lFu<Wc)-qd-BZXaCkmdOG<,$/
-HSIZHJE1(>@Y)sM/Kimo1.SC1EE.C5D#/l;M53EKjA,3"\B_6d'J72_SmnpInP+4NQg&gI@
U'306:K@h36&o\?6QkZ"+-ZnBfVlH>gboo^dB;ZR=-cn>ETeA#6g')K4`N_9hD-+4AJ\@#,b
mAKlK\ehWQ>S*;?2pJu(hf[^KH2Mpt535Z=+8bJF,U`-^B8I.A+XNbmKmSW2VKZ]AkXp)W+Z.
Wo0espF2!:']A-)>IQ>aiqOT0r&M"RC=W\(1;K+!Do)b<V_HW_ed(8jjOk*`15/[$X@nkDtV2
89oJ)&nCebH.QAMm#?7@8*^_kBnV?`H-+Jd('6SS?_C?J%XfKc55.(I<CF!<]A#d?dCTA0M'X
c9mOr,US4F<@kmQgWR3(B%`Atpc9s_V74gTC)FSIKN"mkE81YV7>uKX2%8<2555%?T1h,)Q7
>u;rXB<,VLr0U1Dk2OgIBbrDI*U_FWl]Af3?8Lh?'F)T9QJ<j+dI3LlXD/X:1V5j^`#>ci3(=
h7GG[Pb4QH*R_Am1UGSK"_V?t(LKLkg2.2''#IFQ$'#/!V^g\G5jU2`UN]A.l&1)Bq]A,2e8ma
s1O)qU"XrJ"i"5==IE6_7RrZcr<OiQW^_4Knu,hoSu-5*\GY]Ak//N:YZIR34M4.<[!.g2:ZF
%Yi[DL3T3Ht`%\aHPonN^2U5'5,?TQ]AS5+WRE:jfSU4@8gPEo\?c)A![f0*iHco,M-:8SLM,
gb/TV-_4m`qRWZLnU:<)e`eX(KlZhAUS1U@*r0`P$fro::^u<15oAW#4BlkJ`nAVT%+QC6Sq
r8#_+S8pl7R2V<A3O9]AosS(b,sV$*#an+f%[inf4iWm4jb909^T9de$W*RD55`DO14?h=(LA
T&e]A5!NJZSC0)W8DPQTago0+b;^d+Qqs6d+UX;2r)t'a&A8/-u)llY"))/(q\+(E86+`UpW$
)sVc.TC7?Lq^H*O4lNM/in19:l!)$P=>(9GVT?q-'2c/n)HrO*?6kQc)<=)64co8F0aH30q?
HTAaO]AagVf9SHObm/dA6$F)*:5Jk1rBlE[5*_&c$_u!Or;1KhN(n,Vd-G3)4A[`k`7u5nNl(
J[l/cgFV<V#.FeTQqY5.dKUnkH"rChCOgsM3Qe[FM<E_EL@UVI-J6GlC08h3d.j7%/2)t9E\
.Iam+$0IZXLlhC5?$i;Rp0&HZRD>:#S<Yk-=2<LL3l$m^%ZrMKKO0h3hdZLlVMrBa7N[!/`>
`uoPbl7M[TVo`4\649b*59T$bJUjJQ4d/E]A0=Ct"CQL6n=)^/t#@j!KbM<`bLp>nNtO<M0h3
6Yr-ES,Uj=P_hCah2?^@A[ZT$b#95ektUs,_u(@Z`W@RLiL=Q]A6%'t34&ibpLq4WR6N\5aW*
KS,>)@4FhY"5mAOAf&l8KJnhl[4K"`,PZLUn/8_KD&EgNGq<RG]A8q?lN9W<J8@^2[fG=.O:V
9p;T3BXa]AdUaEY*HpC$[g9K-U\r<'h:(5<*5nT84O=D'T'c&qaV7k=sM@_V1qCMH1,m<jfUk
ltZg)8Zr[I$F5J+=UeQ8p*+BlGp<a5^Fg'eqCZkXfTt.<;&D'Aqoi8N:',qq"t"]As!&(Fp<+
A8I=VZ-\uSAMY"qW,QQLM'6p3a3"P=YoPDT=s.(HD952XRG.^c<-5a"-uO[#d_\pD/4QfN5M
>tpa4[pM6C_eS<)[Sf?Gs1`4@rXZ#W6Hp>7UND*mC?Fu"Y(P.-\H/PSf/_<R$Jpt1@Gc2;j5
e.W">Dq#`i-Bi9:O9?\r!?%`-p*TLc-f`'!A7OO``im4qi+oMmoQ0"EL@oi;CDS4h#6_otPk
<B@\ZIZ]A4dt4Ti,H,me^_T7O<TL7.AprGJ@[bLQBoU%Tn56_T<rJr`0rD>&el%j'rL9s]A,#Q
Qr]A@k`lopj\a9,F0W/q1I"//7?II!p`IYOoU^,8NJ*"12`pbm^nfd-P]AI,[i/jSp3^qEfm,C
7lqU=+hp*;m_,0EY(USq[1,l1;&Co]Aj9&W2\h)H&YUQNhjK^^c]ATpq9g@N1,GACaI`1`B_Wh
7d8^FL77rQZqdD+qCu<O?Z?ma'YaJ7cK3"NnWM7A$Q2O'r5t0VWNr[,E>>u7V8WBgF7B_>8(
QdUB-;t$oV)m5bGqnn`FQ[A7Ta7#H^[*.L".PV<a\D(ee5\@+r7>\.7EoX%r]A5_!H-@*?eh[
sU4IPD(^>Dlr]ALmAZU5I?kq_oLkBjqk\\uV*9rWKcd(^mQ%l\jWNHcIYbGiq#hY#%MJ%BCl=
o)S7H?YB\aJdW]A+/e"1VMn*3"OcnV/8u_mR2-lVf8(n#faIIH*Dke@YPik5+4LekT,=f!\"2
+GN;AjVB9Oj@0!q0#%471dFF4ks?-i7aCrQuZDqfEho=`_i<LPYji^%`j=[ajP5)TrYMPo$k
;F88Rbg]AmAD0a.a'2ele+HW^aK.0qaSbd83IcIMjrY]AYI0KB,5Uuo4U^?J&WJ-4ghUfe>:aA
&XS=8KWY12`;e!Bg3:m<Hb&j5*>>mQYiq??qok;9UsZq+G/9@&Vs":4@EsmFT#Fj?KLR-bCR
@&p"*4!'O$2QM`-I!@^<bF;=R59[QkCV1jAXHd+NnfBrM$T^NBP`*J[#ROg+%O=Ql*ND!%u[
8C5T+?o',Fd#CW1W.SOH$QPEjdEh]A.kWEN\l%YCAMe\jjgPD;^,b]AM3m=M6*<26KM+!SDM`M
EiS4;s%pTM@m]A0D@"85*-2p+P9L"P9L>n\?7;s'#8hY2/6cii@-ID8(0FCn9MX/Wt\')00*[
6)e3ErI%D,qSDSMf-2M`p0mgLa"NlgYI@D-48pSjV54)Ms0YplqAH+YoC[BIhZe<-]AE-jhDh
'd^)rM1p#'^6_!T!fpJ2b7_i!o2U5@B&020.o!r%g&3k&^=kB!&fOYFbcrXZHE!/Y.(b6D)m
AD?r1S)o<'Cs-(=[%ml\BmG#shIXSQ1G!',Sf)*aB!!~
]]></IM>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="0" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="417" height="44"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="247" y="5" width="417" height="44"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="report4_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report4" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report4_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="1" left="1" bottom="1" right="1"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__54747B55D03CBA03B526498E03A03464">
<IM>
<![CDATA[lO<9(kN.ld@UNU%p%320@UNS-%`Gt=fRP082QODE0Slk%FE%_gR.L%J`_9u7&_B:u;caoN(\
-W&+$LXt,W.<hdBSo"Y`<_>q<$T;s)7=b3A]AI,Z?K=A2XWYBs5s@aBh`'Zqm1S"0:Q2<PlnS
K'`.fIgqM`#'*CThq'-1gBiE*j^u-om!Z7X=r\D\+$kq.f(`=/c#Qk0tiCRZ;OSj4=&4fibW
-kIr?/Jr%hf%5"MDd!lf?`3!qs0T\@(H(I(d"aF<;EK`;<=Rq8!T,b+&tM)HrTp?nknMDb"%
_X.N_YSWdIeAW:IctI#jajr;6KVVj[>5)&Ntpld&c$NqK"TdeuFu<Yk/2OF()LLQ@#FJ<\ft
HZ.&CCRZDI!&Z%k5.WJQUTunPl592]AcPnJc:MU$CPeki!cXiYG65'>~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[723900,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0" s="0">
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style style_name="默认" full="true" border_source="-1" imageLayout="1">
<FRFont name="simhei" style="0" size="72"/>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[lO<9(kN.ld@UNU%p%320@UNSDARJmUj^81JoJ+[XARLVpm-3LH;DI@ZNJ!YC%K\2AQN*:FR@
,;KnBH4$JT]A5Pj>ZP2Z^H;Lr;GM9qERa`$',gFm7ioP0lI>snpb-P1)b6:5:$_-TsaVP:0,]A
M'*=$i;=4+]A#;I'E`4L8GBE_Bh-4m9s#Zfm23=/)6GYMTId6W[i5h#o[<No>!1cReV-)4X6[
>nuBeN0^Q<9pL6;6?Ts8%"@l*S!3NF]A@\*ekrQE>">u\C)thcWg1k5CUPV"K=O_Vp4$lF4M]A
&Mi<e)*TF*Do.R\D]A&D2q=acS(kqS_BT`r8a!`?7HB=$N$o:'jVp~
]]></IM>
<ReportFitAttr fitStateInPC="3" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="1" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="233" height="302"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="2" y="50" width="233" height="302"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="report4"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report4" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report4"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="1" left="1" bottom="1" right="1"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__54747B55D03CBA03B526498E03A03464">
<IM>
<![CDATA[lO<9(kN.ld@UNU%p%320@UNS-%`Gt=fRP082QODE0Slk%FE%_gR.L%J`_9u7&_B:u;caoN(\
-W&+$LXt,W.<hdBSo"Y`<_>q<$T;s)7=b3A]AI,Z?K=A2XWYBs5s@aBh`'Zqm1S"0:Q2<PlnS
K'`.fIgqM`#'*CThq'-1gBiE*j^u-om!Z7X=r\D\+$kq.f(`=/c#Qk0tiCRZ;OSj4=&4fibW
-kIr?/Jr%hf%5"MDd!lf?`3!qs0T\@(H(I(d"aF<;EK`;<=Rq8!T,b+&tM)HrTp?nknMDb"%
_X.N_YSWdIeAW:IctI#jajr;6KVVj[>5)&Ntpld&c$NqK"TdeuFu<Yk/2OF()LLQ@#FJ<\ft
HZ.&CCRZDI!&Z%k5.WJQUTunPl592]AcPnJc:MU$CPeki!cXiYG65'>~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[723900,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0" s="0">
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style style_name="默认" full="true" border_source="-1" imageLayout="1">
<FRFont name="simhei" style="0" size="72"/>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[lO<9(kN.ld@UNU%p%320@UNSDARJmUj^81JoJ+[XARLVpm-3LH;DI@ZNJ!YC%K\2AQN*:FR@
,;KnBH4$JT]A5Pj>ZP2Z^H;Lr;GM9qERa`$',gFm7ioP0lI>snpb-P1)b6:5:$_-TsaVP:0,]A
M'*=$i;=4+]A#;I'E`4L8GBE_Bh-4m9s#Zfm23=/)6GYMTId6W[i5h#o[<No>!1cReV-)4X6[
>nuBeN0^Q<9pL6;6?Ts8%"@l*S!3NF]A@\*ekrQE>">u\C)thcWg1k5CUPV"K=O_Vp4$lF4M]A
&Mi<e)*TF*Do.R\D]A&D2q=acS(kqS_BT`r8a!`?7HB=$N$o:'jVp~
]]></IM>
<ReportFitAttr fitStateInPC="3" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="1" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="432" height="178"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="235" y="170" width="432" height="178"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="report4_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report4" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report4_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="1" left="1" bottom="1" right="1"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__54747B55D03CBA03B526498E03A03464">
<IM>
<![CDATA[lO<9(kN.ld@UNU%p%320@UNS-%`Gt=fRP082QODE0Slk%FE%_gR.L%J`_9u7&_B:u;caoN(\
-W&+$LXt,W.<hdBSo"Y`<_>q<$T;s)7=b3A]AI,Z?K=A2XWYBs5s@aBh`'Zqm1S"0:Q2<PlnS
K'`.fIgqM`#'*CThq'-1gBiE*j^u-om!Z7X=r\D\+$kq.f(`=/c#Qk0tiCRZ;OSj4=&4fibW
-kIr?/Jr%hf%5"MDd!lf?`3!qs0T\@(H(I(d"aF<;EK`;<=Rq8!T,b+&tM)HrTp?nknMDb"%
_X.N_YSWdIeAW:IctI#jajr;6KVVj[>5)&Ntpld&c$NqK"TdeuFu<Yk/2OF()LLQ@#FJ<\ft
HZ.&CCRZDI!&Z%k5.WJQUTunPl592]AcPnJc:MU$CPeki!cXiYG65'>~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[723900,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0" s="0">
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style style_name="默认" full="true" border_source="-1" imageLayout="1">
<FRFont name="simhei" style="0" size="72"/>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[lO<9(kN.ld@UNU%p%320@UNSDARJmUj^81JoJ+[XARLVpm-3LH;DI@ZNJ!YC%K\2AQN*:FR@
,;KnBH4$JT]A5Pj>ZP2Z^H;Lr;GM9qERa`$',gFm7ioP0lI>snpb-P1)b6:5:$_-TsaVP:0,]A
M'*=$i;=4+]A#;I'E`4L8GBE_Bh-4m9s#Zfm23=/)6GYMTId6W[i5h#o[<No>!1cReV-)4X6[
>nuBeN0^Q<9pL6;6?Ts8%"@l*S!3NF]A@\*ekrQE>">u\C)thcWg1k5CUPV"K=O_Vp4$lF4M]A
&Mi<e)*TF*Do.R\D]A&D2q=acS(kqS_BT`r8a!`?7HB=$N$o:'jVp~
]]></IM>
<ReportFitAttr fitStateInPC="3" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="1" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="372" height="150"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="3" y="386" width="372" height="150"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="report4_c_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report4" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report4_c_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="1" left="1" bottom="1" right="1"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__54747B55D03CBA03B526498E03A03464">
<IM>
<![CDATA[lO<9(kN.ld@UNU%p%320@UNS-%`Gt=fRP082QODE0Slk%FE%_gR.L%J`_9u7&_B:u;caoN(\
-W&+$LXt,W.<hdBSo"Y`<_>q<$T;s)7=b3A]AI,Z?K=A2XWYBs5s@aBh`'Zqm1S"0:Q2<PlnS
K'`.fIgqM`#'*CThq'-1gBiE*j^u-om!Z7X=r\D\+$kq.f(`=/c#Qk0tiCRZ;OSj4=&4fibW
-kIr?/Jr%hf%5"MDd!lf?`3!qs0T\@(H(I(d"aF<;EK`;<=Rq8!T,b+&tM)HrTp?nknMDb"%
_X.N_YSWdIeAW:IctI#jajr;6KVVj[>5)&Ntpld&c$NqK"TdeuFu<Yk/2OF()LLQ@#FJ<\ft
HZ.&CCRZDI!&Z%k5.WJQUTunPl592]AcPnJc:MU$CPeki!cXiYG65'>~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[723900,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0" s="0">
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style style_name="默认" full="true" border_source="-1" imageLayout="1">
<FRFont name="simhei" style="0" size="72"/>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[lO<9(kN.ld@UNU%p%320@UNSDARJmUj^81JoJ+[XARLVpm-3LH;DI@ZNJ!YC%K\2AQN*:FR@
,;KnBH4$JT]A5Pj>ZP2Z^H;Lr;GM9qERa`$',gFm7ioP0lI>snpb-P1)b6:5:$_-TsaVP:0,]A
M'*=$i;=4+]A#;I'E`4L8GBE_Bh-4m9s#Zfm23=/)6GYMTId6W[i5h#o[<No>!1cReV-)4X6[
>nuBeN0^Q<9pL6;6?Ts8%"@l*S!3NF]A@\*ekrQE>">u\C)thcWg1k5CUPV"K=O_Vp4$lF4M]A
&Mi<e)*TF*Do.R\D]A&D2q=acS(kqS_BT`r8a!`?7HB=$N$o:'jVp~
]]></IM>
<ReportFitAttr fitStateInPC="3" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="1" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="578" height="153"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="359" y="383" width="578" height="153"/>
</Widget>
<ShowBookmarks showBookmarks="true"/>
<Sorted sorted="false"/>
<MobileWidgetList>
<Widget widgetName="report100"/>
<Widget widgetName="report2"/>
<Widget widgetName="report6_c"/>
<Widget widgetName="report6_c_c"/>
<Widget widgetName="report3"/>
<Widget widgetName="report3_c_c_c"/>
<Widget widgetName="report4_c"/>
<Widget widgetName="report00_c"/>
<Widget widgetName="chart000"/>
<Widget widgetName="report4_c_c_c_c_c"/>
<Widget widgetName="chart0000"/>
<Widget widgetName="report3_c_c_c_c_c"/>
<Widget widgetName="report4"/>
<Widget widgetName="chart01"/>
<Widget widgetName="chart0000_c"/>
<Widget widgetName="report3_c_c_c_c_c_c_c"/>
<Widget widgetName="report3_c_c_c_c_c_c"/>
<Widget widgetName="report4_c_c_c"/>
<Widget widgetName="chart0"/>
<Widget widgetName="report4_c_c"/>
<Widget widgetName="chart1"/>
</MobileWidgetList>
<FrozenWidgets/>
<MobileBookMarkStyle class="com.fr.form.ui.mobile.impl.DefaultMobileBookMarkStyle"/>
<WidgetScalingAttr compState="0"/>
<AppRelayout appRelayout="true"/>
</InnerWidget>
<BoundsAttr x="0" y="0" width="960" height="540"/>
</Widget>
<ShowBookmarks showBookmarks="true"/>
<Sorted sorted="true"/>
<MobileWidgetList/>
<FrozenWidgets/>
<MobileBookMarkStyle class="com.fr.form.ui.mobile.impl.DefaultMobileBookMarkStyle"/>
<WidgetZoomAttr compState="0" scaleAttr="2"/>
<AppRelayout appRelayout="true"/>
<Size width="960" height="540"/>
<BodyLayoutType type="1"/>
</Center>
</Layout>
<DesignerVersion DesignerVersion="LAA"/>
<PreviewType PreviewType="6"/>
<TemplateThemeAttrMark class="com.fr.base.iofile.attr.TemplateThemeAttrMark">
<TemplateThemeAttrMark name="兼容主题" dark="false"/>
</TemplateThemeAttrMark>
<WatermarkAttr class="com.fr.base.iofile.attr.WatermarkAttr">
<WatermarkAttr fontSize="20" horizontalGap="200" verticalGap="100" valid="false">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
<Text>
<![CDATA[]]></Text>
</WatermarkAttr>
</WatermarkAttr>
<StrategyConfigsAttr class="com.fr.esd.core.strategy.persistence.StrategyConfigsAttr">
<StrategyConfigs>
<StrategyConfig dsName="同比分析" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="部门销售额以及达成率" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="日维度销售额" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="BI" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="日维度渠道冰粽毛利率的副本" enabled="false" useGlobal="false" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="线下排行" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="日维度成本分析" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="京东销售额以及达成率的副本" enabled="false" useGlobal="false" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="五大季节品" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="各季节品销量" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="年累计销售额" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="热门产品TOP10" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="时间维度销售额和成本" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="利润" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="BI2024总销售额" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="线下分销业务员目标达成" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
</StrategyConfigs>
</StrategyConfigsAttr>
<NewFormMarkAttr class="com.fr.form.fit.NewFormMarkAttr">
<NewFormMarkAttr type="1" tabPreload="true" fontScaleFrontAdjust="true" supportColRowAutoAdjust="true" supportExportTransparency="false"/>
</NewFormMarkAttr>
<TemplateIdAttMark class="com.fr.base.iofile.attr.TemplateIdAttrMark">
<TemplateIdAttMark TemplateId="31dc8673-ef37-4837-8e01-4fc1dbdb3446"/>
</TemplateIdAttMark>
</Form>
