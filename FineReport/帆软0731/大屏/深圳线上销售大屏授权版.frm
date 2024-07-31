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
and 渠道 not regexp '样品'
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
round(sum(ifnull(实付金额,0)),2)  总金额  ,
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
,left(发货时间,7) 发货时间
from  
profit.dw_吉客云销售明细单 
where 公司 regexp '深圳' and 部门 not regexp '私域|线下|分销' 
and  left(发货时间,7) = date_format((CURDATE() - INTERVAL 1 DAY),'%Y-%m')  
and 渠道 not regexp '样品' 
and 实付金额 > 0 
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分'
group by case 
	when (渠道 regexp '天猫|淘宝' and 渠道 not regexp '天猫超市' ) then '天猫旗舰店' 
	when 渠道 regexp '天猫超市' then '猫超' 
	when 渠道 regexp '京东' then '京东' 
	when 渠道 regexp '拼多多' then '拼多多' 
	when 渠道 regexp '抖音|快手|视频号' then '兴趣电商' 
	when 渠道 regexp '得物' then '得物' 
	when 渠道 regexp '小红书' then '小红书' 
end
order by 总金额 desc limit 15)

select  round( a.总金额/10000,2) 总金额,a.二级部门,a.发货时间,
case 
	when a.二级部门 regexp '小红书|得物' then round( a.总金额/10000,2)
	else round( b.目标/10000,2) 
end  目标 from a  
left join  profit.人工导入bi线上电商目标 b
on a.发货时间 = b.日期 and a.二级部门 = b.渠道
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
<![CDATA[
select round(sum(ifnull(实付金额,0)),2)  总金额,sum(含税单价*销量) 成本 ,(round(sum(ifnull(实付金额,0)),2)) - (sum(含税单价*销量)) as 利润  from  
profit.dw_吉客云销售明细单  
where 公司 regexp '深圳' and 部门 not regexp '私域|线下|分销' 
and  left(发货时间,7) = date_format((CURDATE() - INTERVAL 1 DAY),'%Y-%m')  
and 渠道 not regexp '样品' 
and 实付金额 > 0 
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分']]></Query>
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
and 渠道 not regexp '样品'  
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
<![CDATA[select round(sum(ifnull(实付金额,0)),2)  总金额,sum(含税单价*销量) 成本 ,(round(sum(ifnull(实付金额,0)),2)) - (sum(含税单价*销量)) as 利润  from  
profit.dw_吉客云销售明细单  
where 公司 regexp '深圳' and 部门 not regexp '私域|线下|分销' 
and 发货时间 =  DATE(DATE_SUB(CURDATE(), INTERVAL 1 DAY))  
and 渠道 not regexp '样品' 
and 实付金额 > 0 
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分']]></Query>
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
<![CDATA[with a as (
select 
substring_index(渠道,'-sz',1)渠道 ,'销售额' 类型,round((sum(ifnull(实付金额,0)))/10000 ,2)  金额 from  
profit.dw_吉客云销售明细单  
where 公司 regexp '深圳' and 部门 not regexp '私域|线下|分销' 
and 发货时间 =  DATE(DATE_SUB(CURDATE(), INTERVAL 1 DAY)) 
and 渠道 not regexp '样品' 
and 实付金额 > 0 
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分'
group by 渠道,left(发货时间,7) 
)
,b as (select  sum(金额) 金额,substring_index(substring_index(渠道,'店',1),'渠道',1) 渠道  from  a   group by 渠道 order by 金额 desc limit 7)


,c as (select substring_index(substring_index(渠道,'店',1),'渠道',1) 渠道  ,类型,金额 from  a )

select c.渠道,c.类型,c.金额 from c 
join  b
on c.渠道 = b.渠道 order by 金额 desc 

]]></Query>
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
<![CDATA[select round(sum(ifnull(实付金额,0)),2)  总金额,sum(含税单价*销量) 成本 ,(round(sum(ifnull(实付金额,0)),2)) - (sum(含税单价*销量)) as 利润  from  
profit.dw_吉客云销售明细单  
where 公司 regexp '深圳' and 部门 not regexp '私域|线下|分销' and 发货时间 like '2024%'  and 渠道 not regexp '样品' 
and 实付金额 > 0 
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
<![CDATA[select round((sum(ifnull(实付金额,0)))/10000,2) as '2024年',concat(month(发货时间),'月') 月份 from  
profit.dw_吉客云销售明细单  
where 公司 regexp '深圳' and 部门 
not regexp '私域|线下|分销' 
and 渠道 not regexp '样品' 
and 发货时间 like '2024%'
and 实付金额 > 0 
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分'
group by left(发货时间,7)]]></Query>
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
and 渠道 not regexp '样品'  
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
<WidgetName name="report00"/>
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
<WidgetName name="report00"/>
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
<![CDATA[243840,1143000,1143000,243840,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[1752600,3314700,1828800,3535680,1828800,3535680,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0" cs="6" s="0">
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
<O>
<![CDATA[昨日销售额]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="1" r="1" s="2">
<O t="DSColumn">
<Attributes dsName="日维度销售额" columnName="总金额"/>
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
<C c="2" r="1" s="1">
<O>
<![CDATA[本月销售额]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="3" r="1" s="3">
<O t="DSColumn">
<Attributes dsName="月维度总销售额" columnName="总金额"/>
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
<C c="4" r="1" s="1">
<O>
<![CDATA[年销售额]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="5" r="1" s="4">
<O t="DSColumn">
<Attributes dsName="年累计销售额" columnName="总金额"/>
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
<C c="0" r="2" s="1">
<O>
<![CDATA[昨日利润]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="1" r="2" s="2">
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
<C c="2" r="2" s="1">
<O>
<![CDATA[本月利润]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="3" r="2" s="3">
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
<C c="4" r="2" s="1">
<O>
<![CDATA[年利润]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="5" r="2" s="4">
<O t="DSColumn">
<Attributes dsName="年累计销售额" columnName="利润"/>
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
<C c="0" r="3" cs="6" s="0">
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
<FRFont name="微软雅黑" style="1" size="120">
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
<FRFont name="微软雅黑" style="1" size="120">
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
<FRFont name="微软雅黑" style="1" size="120">
<foreground>
<FineColor color="-472193" hor="2" ver="0"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[m<WDI;d%j-1VS$$SIn.!(dS;#WDj2C!GOhBd\NXi,!nOe#S9OKPbKuD&JPKg]A(Fh\,Sl7L!G
MiOOsm"0+bZ<2P+9=8jo+pZkPRF!jfcA(f7)<-cd#JWqd/S+aP-"E+n7od6:+0obcf\,$13u
k'&)Ab@%Z@Lnt&NH+ebrZ(>&Pm&'p]AB*,`?72a[A7ag52X^Y-aM9QRl)fKWn1FO$O8"%5@g<
NgGMYiG^j>t10EhoQOup:`Z[r9q*j*o.J2]ARB<C=)b0jERTId0*+R,Jo<gKI_P?9R&^"S<d,
H7X0st!T&]A1XN5gSDY%Plrp/)^10IEiZ>;PjTJa6?<D>Nsmd%d]A*L40(7')L`X;W">nJ!@@s
[RWmP&a6\oA\2SVj\ae$9J5/?!WMbpTpqo.GlMhS(.'lOd%c3AB<u+lmjXR<*MMgm1dKTpMm
Y`.rj'?-(0oatRR_j0c%]AMERcf?(EtHmIo,O.UGU^/k(EoL4^mZ;O\V&&n\5uC7m2S@TmhZW
5qh@E?'.Zd4BRFum,e4-Bh#K\rW8neB;=J1)p`,Q!#T7$R8Gh:D4.H?c((trf'm,jZN%79j2
]ANUQ<ICqn*PlkuF]AhB_L($'0Ie5rQR:ITm4Ed6CXo62(iTXhEr?>YW;<s;&<t[3AUl":hA_"
A;fp%MW9)QX/[I*o(O7^[H>&7+_\G]A=G$?ME<):f:GNfdp^3*YX<mV2rHGC8.0;laOBrg%Fs
gJKafS;)P+<1`AsNn1leJi:;"1H3q^OP.(Z6H0K1oT$A#7XincrZF[c)-F'b%#r]A9>bpmi"0
cq6&Q_]A8!4_\f4-lphB(#mPIc"gmG']A0mAflI;$L3Y1E$+6Pn!E.P+\V,c%[-[2W)>qMmrn?
fRqAe@b,]AF-?=*5I]A@+BY*3[8J'3bulp6_,rKG\jh6\<//2+9Ua6+^KFc3XDDn>B'Ti5Hfqi
g\2`PCp?)pM5EaDn@$aNNI]A:R>;M"NAo9J[Ne,-_(7f(G?l0r*9=i@XW;#PRD"-*hT@r=l'4
idjh]A<<5t5Ncle5u!9J?EPHSO.<fX7Ym"?K:)q*Hi=q`&P'>Fs=CC3Dt%Q=SONP"oh2K`$_<
EL-#^lL<t;5+LPF91rHjrRtC<QVTDVP*^**Adg5I<+G=V0hkU&2On)<#Ph8DEWV?a:hgFJF2
@]AJ`NG6S:cF0k'4tXU`o(ladDa=RjKsHdpIg:eTupWj_1qkS#V"A8e,#%XHX]Ah[F*mN&-L&7
-HX:A)69BMjMnMoYj>(VtR"/'-Uqna.Q<ea58:E5!ql2u(8:-3Ai(?l.(&uSZqGcTN:sHk*6
4fQISZ.Y'[V\67bbSp]A-XG/E;2D`_=JhuIkpdDNN9#DiSWHU6BlRAe`&C(7.B2lIW,(b*#AU
pIraS!4+;[1ojV?;=@U>-b&]AU_3c\+u`UQU6<#1)I+lEIWYF!bD72\UrboQk3tf"bY\'Nn).
c(3>HJ'gcbf3+0:qLPf5#_-V+h-.3rUl;nL))NJEfd"?-B'U$M1K)/')Yh4*64AHNeS9,i?(
u@<C=BfeGdTRjGYZjCa*YIFol5Ag>'A01W^Pguo.K^@"heX,fc9H"+XD9Y"$i56T+R!7#p2"
``&DPqY(dH^`J*;Vn&6I[Z2#p9Rsj3Pb2pp>KY/TcGX$]AK)h$5rAl7<8kNbicWnf\lie5p5F
l$Lbb>h**!%of5%,S6gqiQ0ge_82k=j+//=KBPk;t5YU$1tg*#WM@h6A/G;JDf[IY]A.*@qj!
1*5,q[^9Q=S%jRlH+Sq\IqKoAFY__>#rX%tf:'754fY7Q=3[6H*g51:P(>hKf>CIE+`q"2D_
[C4B1`[BNEg(*]AN.<'cV'<O=]Aks&#)+c2.&BGgn-=%Yl8=C-:p1,p0=1=R>a]Ac*!%isjNJh2
#Ynehbjk2FNr`]AU>,W9@K[4[]AI-u8smFV/cg]Aeb,#IfPQT93:.Q)Y>kaWfEB8GFD_+`iQEpb
6XQo#%]A#)RuoT*LMer4X+>CtTC%(Ct\:'?HF!(rrJnXJS)(/*WN<"5_piKaP$1a=pX;Hq$U]A
YFp61f@O#H="kfZq\9,4%3&c+b99Zr53SM3@.CDfn[?(h3W<s[G%F1gd-E?T90f^q.*k>O5m
]ARUK7hOTl^$aP1Y-I!d>$bkX5f+b0"Y<1rIaRT#[ae[`a;HhoC4J)VE9MW,Bh55(p6-pOK"N
c<+P);4u2'SaV"^Sl3a^Tn@BW@O0K[>`FTu8Z62j##b/fS=fquk.F)CO>)m\">Md`q"LR^qE
ek[Ac#0<N3mkfB38]AY@\mX*U4;/BBN_L_Mkqs2A)?2UfIoEh,YLluAFh'ATfb?0OKGn)HE`o
o\WC\@@.0OEiP%-f@I[?a%DE"7A<"n'C+J_]A'TY[Bj@n:&;9<2NH/B"qb'"4_7Kbe6;R>$*o
SQhfqY,AI!d<r]AHNccdM<)QU7,min&(6830+06(4,^a^YmmVCOnk33JJ8n`IV2sK9e0#Z["J
2lHkQsgI>Y*XrZ.@q8fF=;.1!O-a[F:<<2cJn?0rEXQr)e3+fOX_W9sJ>:WHIuOOs@Bpfh0_
O>i@2$O\Q#5^Gkc=]AT]A$GFCmKafE^QKTWPMafuK0D99-F%LgHHFK*!M_2oVs-5CP*fMJ)Y??
Tk<BL:[S?b^)>84bW66lAfDXDS\lXcl[u8a1`4($e?%I@D-9?R:]AZWNue0D@MEDT'?5<AZtT
XR-Yn7-ki=/b$M&H\#gf=/I7a]Alt06n_;>WT2mW\t:g)hZbWdVo#+IKbgV_4>bjA_M!pDR/@
1'#!,aXp8T2?Z#PDm)%RssZ8#Dl5+_FXtA>eR^4b4EN-<jug?>3=PaT)tUYg<$+SGu6?LpRO
gM,Eu11IL#SPhe4)o0(1D"fegA7>L$dZ'B]A;"Xj;/29<%f;rQpnn;7g=EA)6V]A<"f8[.7qg@
i`Q_WV5*;DIqN'edrk"HAE#.[l:,#n(+spm`Pj=2_FCtONq\Zq!"4YF"$7)@<\U%pbZ!&;#-
-p!>Y[USFkun[*_(`;*.hE/N`R1fD:FL#Ep/jSjPU6BgUsCJ27jA+Nu"'@#'faW>t@YQR#f*
U3nj6qR]A:WG7W!I'Eo^uCVEudoTApqH3VN0cIFSjLfZMFJU]AB[+Z$h=jHMiVfEMC[bXHM(al
=+$f8TKZq0TNt?@?9ecjO<rL,Sck_C*bhiJ`9O1o8'[L+7&Fs]AO;:`3C5lF3*EpM1MB'TSu.
dn?,F'V=h(b&I8aiGq>kds2Bkt6ak&OUq@Mp*H"o,<k*&m!$ajg.$j"S&f>eM,B`fou%>sP!
o'X86A(l8cC_65_O%'X<a4kK-c=G#T5a=.cdW3WZ]AJ\P<>0c2pAXCFsJDI8!&p(Ae?K>3[N1
uL42DU@*^YAh3oitL`<IV[L@KT2I7bH6D=O7cQc6:p:X`kL<GWX1c7jL*Y;#^EY&I7F=f4b8
Tff`PoP/("P!PZS;O6N-+(!Z1BZem`TTRiX0S(iFr@lPjBV(%X4:[5sm9)a'A9\8kgf%[&s*
'0mhbRJOMaF&!N<nP2b;3n*q]Aqo3R/3n3GRMr+\pC'`Ham.9X0;-K#CkKb$[:1JAE[#%;"Kr
fqE)K]AYEPu60TUen59.$R?<cSV"Q*;2YVc(lQB!+4K$C;V)qf@]A=hR('PHRDGANaJ!YMsS6+
=.hngj?<Z+pqpd2Y52CP.(<<&(*=C')0QgUnds;16baW0_*18m)3FgYJ6Y%QGu.El'eRV(3R
f#.XGU[dXj_W-.iP08k=g'5)OAqB@n&?T'6lJ#T\u?L&jRG7U1s%4]AXldNT^`ZS6-E&9_ZO[
1Br]Aq^^(88WJ`#plC<CZ0Q6<tG0T\1BEC$9$TmpFrP#;h3M.W:@o&J^7a.A$Cj@nt`>b^*((
;/bNGthq`AMmklKE.3\*$5B8=o?Z!l]AL\XD6Bc+=K8u\&7.1P6<F_kRe5g&a?1<OrLui+6!j
qf(Y"g4($TO.&6l%0<rMtjc8i]AWcLYDbnP3mOS31W>Ua*=Y(.P1tNdU]Ae>SnmVU<@GZ1(2Ak
?Ca02V]A;ijGHtEg\Rah-<8D2pM'9UW\uN")iM<J`U?_Z<7JA>n/hNJ10ZX?/3Qp#8HULp"o%
WGK[);igEQFM,I\=FV2`>'KC$tT78P$hK&&lPP9['gH`6@TC*gqoJWq?hf%F!>N_E]ANpo`>^
_+4]ARc[p*MUb-f1-+P"[Rk)TI6oE@06k'/+_(@!*FQD44.)&#d*=]A+:<c!N>?q2P%%HL=d5Y
k@HY/Sr@t/nQsr[ru'e<)ZH&44\`7ja'S=!BJKV*Z\;?`!l2=[=DbTpP3DR@Otg=ZHk59X1J
'?]AQ=nSIL$&:-l.sar1aFf15!a\-hi-EBXK7c]AXHg58"63kT[HZ_*DEe#C'GDae>`9cqL`Cl
Sm'b'Z`9FqUOqmiF+bQS&Tp8"47,S)Q^*9_6VjIC21A:-)dd,eH8gC=<s\-KThmmfg%]AAToq
F^7LY]A8@KGW\Ms.a1&81;uP\i(+,=ldPO@%qk6Je%-b\U^=0J\AKr/[8QN&YYC]A1Pg<YE&"#
Z\D!='EYBR=/CYZ!qXr[3T-,['bH.-&*@6:U'W!In2-K?M?C!Vle7DOnI]Ar'R44gmJhhWu)o
)s6AeY;UN5C`/NTQ_\Oi'm5^NlZLG'-Td*Lt8'mVr1uQKVAeUAJNmRX(b2HU2*rF3/JeSOTL
$HZr@tV$3;tRoM$F\k80SH#\OBqYq:)nG/7J\3/L>`X`Tt;"\BWXE%d/[8"VZ&8QJUKhYD'.
[0hh>/7<1Y"TWt4I(W!HK+1V]A`DF=4RLdKae>eD4q+9@c?k^"?E70U]A3)flB?-3kNl$kT`[j
]Af4`Y\FZ&WSJlC7\^t&(ju*]AMXj73tH#:)I-h_s1WL^ZOM5rLR2l5fUQ"u,+Oj%Y?_T]Af7UE
E+6-eh'"S-e"Ps$b/uN_U:Gq8Mrc0AfW[59`38kK;0$1)/bc7M@GC`Fq=a<>h?Vu^XIEJ-AK
tuHVMF>))$i77(5,\14bZnr6`obARp6,4\Mg1Xr]AO$4i>@d5,#--Bm2QJ"AHO%i#.c)Z4%^<
2'O4j>0M3l*oS=rA^?)A>Oi2,q_[&)]A6(W*GB?3;cTb)@T7>:"fc<=290oY*52HlaB>7eVLg
q9L!4\21oB2_eJE`K[<@5/CLYLSuY7G>\*Hc=GG/8LcAi<DX3P-#_3h.iB1Wo/M\1V5pP2Bi
b<3Y:9DjjC8>a%IV^+G.%-+$krUk?kakhGW81`P!4O!B+.BK2gM))+/RSe%8Z]AF!0bd]Ak%u$
U3C._1`ZpC_VD=6+2D(:2'?,m_e=jAHL<7et:&,E>SHu'/gU6m8p%O:rT,VftYp5AeX8?oa\
N[]A>VBXf.>4/[RjeR$X'b1R1YsPu$p4.&6K>%PU*]AeFM;X]Al*Tl?V9!H7@<.-rLs/96u.dbB
3h02aKVQ_sO9ipB4BPEP*GQr9m-(RksH*t*\._J9)UM9+m/U5*1:dA`Cq'_B!.H\^^U>c,CO
aAAfT(+:*cY47.j.d2pFW+)'Nbfm]A$bP*)AK.m9tI)oZYl\6O=n1ur!P=jgLM@nf"a(eYM9[
P6fo.d,2SO<b3e6a^#G$.I%Ve,bN'4-uQGV>;!k"D0.'D8"N_]A)8>/;P=Mf5/]A06'kS>(-Be
4A7.!?S3f/K1!6Wf`h&Z4QL,E0[\pulj9+gQ-W#rDUX@HSEM*+Z(q+.UAl=jkg3ZSK"OKD*b
,O@n4b_;4KIa24c$j7%ARdPY1O7a^!oC'%j[KAYg$c1#G#+JKqE(6$fV2NfWn_p)GYn<l$/*
[$*-b*.3lN`.8InS!$K;"-3j!qdDtp=D8s7%88MF7X$@ko'$.k<H1s?'SWpQ&ai8"PAdcN:O
Xt_IT/;Ica_dc-;H509]AO&9nkl(0(C$k"N`d$r%>!t60J+uS$G&7@26m`2QN+R&C#7:^2ti+
Hit&HHIBakNg;DXV%;o,nQ<?)&<38h"D=X3F7nb]A$VnNjB_O]A8N9;Un'kiS+F\^.s432o904
[FS#H/f"7Mh.\q,J;Lb6P)a(=K/Z,n[pK3TQm/h(0Eb%i7huX*F^,Zo5Qk;'s>G]AsZR%-Zfi
FLXm^X<IS*VfO;_jmBhQ[N0Q\.B*%Zi$#i^kG;bZCJh'9qa4=`KOD\)D8a+n:SAIWqZt0f-Z
=IJZ[^nB:m[jiglA<Up(fifDuS<(A78i,J*mn/*9Y_((q"W>HpmqIF?Fmp\./0"X\Zk<08^p
UU[Qn]AgG]AYQ^M2'/>c9U63c'(rTEVQh\LNsHND)%b-m$_]Aa!I8QK-kDcm#:`2=:W;ri/9[gp
s43]Au>^-=3("p7]An1$s!T_+CI=TS5-Eiis($Z!9s7mHLm(S:E-^6*q3;oW@$XuYE.f2*)__7
jk[Fa%opr4-$fNC`=KuVq)VD^7q`XaiLG0$0BO#,9fR8V"oe<$=1=/jOGIlWs/Z6f!"6R;*>
JE.Z7"E#Z$!hXP(_+1@[K2ebEA7#^musDLs/afNjetN83lj`V4c/"K!bbe0aW)\KG_dEs_Yf
,61TTO@M6"9iNkR=2:5]AVhY`sBVZA\="qb<+hH:TRbQbd_O).Pk@6I@fQ-td+:0YbYX!6')+
s3TE@LiD5/,fM6Ri5#*5XL'KP1P3\J[N.4/$9&qd/:.9un8`]A<XPA8F=*[-ZQ45_Bo\BPhb8
1*FI7LZ&AE?FC@S6Ppj;?rM@"fK&pTFDJU^dX;O'bT9-O%KXappP5(R?;(2$B<UpPl>F0ujU
JJb%*\/,ai(UfeX@]A\.[[lQ=sMT`C%Cd57lmD>GSb+!T%Q5c0hfY-2`3]A8Ns;R4Rjk42gsSp
b`[6X$!sZZ.8KAb)oX6]AANn%+JkR;nptY7QY3Rq.#@C)_.-sm:QaS/djK%9A\@JX1?6`IggT
Pu;/u"6=c8$e&0SWDq!;`CISc6W<h#I3)qHdMKca0(Dm]An3@a."6*KV52?=;VunaFtfYW+_b
adkBcWdr6\SGk+$lIF5`qMkLj%BpIu=%RuZf1.KF$Wgj0e4b',2\qWOX7LC.D88tD.AES'dC
.nhi<.;)7=EOUaGDO3'MnH'R*7r\(R$iNk/ed^8V<tBm2I'o(r%@!^aW+sp<0Uq$'M4=X=3O
oDP^q:8>*4lS(>ODM2a3l?Sl-ld*\2sl.b3$dOR^?^K#()\]AYmo0l2qM<JKO#Z='ihW%U(t=
$RD`F-E"X<3$rsjC;`Z-_W\A;nFEU7#7rYqao8j7%RGfD2U8*qrTpI+faqtZE<kF/m$JBHa]A
;?Smpe+P/<j]A-b7P&@b8lBWs8(VSt&((Z/JQ\;1)f_^m(^72%qcDZFphlIo#75b[n.2ZDJhj
Y%>El8"ppV"lVV)T<EL`co7K93:-=?jmJJkIp1%M>N*_NPP+78H^q(i@#*qf&o/q+-T_\ObE
ItVcG?''HD7m9*>n0c1)m,[/>-oY:Q\'A&7.FHKGq,1@H4@R_\L]A^4=T9Cr(oeBCLuMZluo%
9esIWXC:i[F.7.J&mDMP_J2HpCJo0<"A@%RM,PHEh?Sou,4uD2<8^IIuOt0lgX,5_DAnKZg.
&^*h[db2sE%kr+)]AE9c[P1,%KdLXe0#N@Q-@5([Cq(`*M,"FtBg1:k:2PZf&LKCu$5u#Yrq(
I9fI7X6`\+3o*u3\pg[+3[Brj3S^,WX<%opGS'rGBqbfr'c;]AF[&)lZaE(b=[`m(0,AMma4:
qLBPBfa2[XP..G/f<ZMPlM+bZ!&Q><$d18fe&G0$'@]A^]A?B.mXNQ9!Bo4!e?dlr0Y3)Db\U*
tMg;GW-N*KK_IiNrL(NAV@_Sj2!4qb#KSI8\ijl?`n"<Z4iTKO]Abrl(ORYVKsk;D<2.Bi0?6
\)tRU78HR4-))Zlu#4lk/:uPZ7/JPD6%h\"Pkkl;lo1WOCd396Qo_GTVl.,$^M=:c*9:6)l?
0i8oP\[IC)nV.criniU@f6gdBnKX.O483Fp>-m`M]A(,VO?m.SqdiasiLd"Q"(+8hP3TZo,E0
T)7@NkY6iS]ALNh#338cT[1S3&uuSX<%eTNe6c%r;B]A3=Y'J5k`VDL5j*tmKQng*SaZJDbbQ7
<SLP_%AWQNJW0sSa@glDo&`:jh$djkj&6+M*GHR%[Cn1HA5ASh)82fi9(J0&QE.B8QdRO'CA
3@H46$\OjSNI9G8hDAnf5PK6j#'q/pA_X(?>e7.`I9e)@_-*)=3:*qL=e;E?ff;A%ArRktb=
uW-R\g<ICE)5st:YZ*\!Gj\dO64if5U(b-8P=P>*-JB))>-?li?R23=p+,?NFn&u*47COmV^
puA9aq.OL>>[s[e/:fA'+F9_2FS75;706C]A_S%=e(3:*'I#fR]AX\TbHjAIjEj4u!b'Y*^\kG
GfF*6iceuN?LmG!&'*j8eCmcqKeJ3]Ae$p<D!]AonScfW%r_eMdg>k!JDCL?q.:&+(egPHg=k9
pHLHs31,if<2p/O)SK<b9KL$D'X2<OESXdC%>?<O^7i83YC<lQ\b,#8ZI4%`eAi6lQ,lNMn?
\#-AD=/T_E"bpS]A)PC6-CuK9VadI<n.W8BO@W]AL%%mThkunDdo')^pM/ID9F;$98OA@!Xtg3
QHMjh+gGOVh<Y=a%hVMT4ECdK?8XRijLu836oYSA'>p!?KW0B89WVUr\MgnB;4R#XXCNR?c\
]A#bpG+B2OW;h3]A0F&:3Mnj6n2pS"A)X*Ms5.KNr.3)c^(fb`^h_pkY(nd%On/CUA/ZaW,Pah
sHJ7E4:_W]A?4\Sd.9^`(0-T[=NEpt^M^3Njmq#k->?>uS8-4RODX1MLHHFu$iLjW3Tj9l&P,
lokZ.6>9JDi_Y&UM:KsuD7ju5C<G9.8B\BR6A/uuqNs-7Q.O0u``G4Nmp_sAFARrsF<*fOaM
N@]AM'/<5rgV2h;4a7^f7?@@Nb"HO`]A_q]AkRu`UH=e_D/QfEV9-:1[GZ`!/I@6_QF3^CB%OAX
'6LC1.c-pT<;B/6HUO6oGaP-#Tb<IG3$D!o)Ke(ESj<l#0W7ANNDms!pj:*s3e1Pp@57dkh2
OsX;<nmY[#S^oF32n4:03i@H*'UiS6N62`Smn)^C"S8[bJCVbWo'?en*g)a,Jlj@I'//&Qc5
N(V3Nk$O4ec),:2E#<!VAM!L9lGcoB\>\r)j]A?Yfu"I8():8U4_f&OYI%'a8&gc5lGA!9/m;
'i#_.>R+a2N-<j`WGd4DjP.T$/iPEnRM2>ap;)0NbXN,*`qfcb[d5&Y%lS`k;#5fH8s3`#^#
U`M-M%Ce/<XGa:+:ck4R@4Q^W)&]A_-H2jZ"Jj'^$[=+&)5R!UEBC<9J]AU>(6?iME723BlhQ=
=,eq*=O]AfLpd[=f/F`q4AXK7..Ak*ga_2I`QLcU]AbP<9Z<$PU=a\p=>PTt9*D?=/e_De^n1G
%$m7e;,g-1ZADuD%5]AF:<AA;-aLAZm-1C8-C>>3]AR/M$o?i22:eS#R-%nDqE@a2!L<)b1Aa%
QA:,)O3=cM>;e8_WV]AZh/?niPbOa5<]A<P/2XeNE/l_;#V")5Xbj(09:CaQ$4jS$Vs2f0;G6Q
ZQfd\/unN%p_,lb0G!=sRlR]Ap`RCt:^hTf1e"U/iSo7Kq%:&/Q/(mb/P:<@E]AL[K>2e\U`i+
3.u>nO9B:`RaQoSPq$MEFEA9RiL6hHqcZ,`Q<+$B5?*2Og**&sVbg*L_ro)Nrk.oE?S%rET1
EIjP!08mVmah$q0DY$k^\MbZq2Os6]Aa`fOL-#r%9_X:Km1XKgY1\D?nR)IMNb$F6QY2AZ+.;
G(s$Sn-<d=<sT+dk"R/"/[f9?X%^DmXD>kGdp`GJPC[;>,tiSW474C)uiAQ,pBS;71eg[b`W
]A!q8GN&eLXO96XQmZPPuQ_kS>@E0mlX+2@K#)_t:eCB%VchU/+-mYrmC*.]AlQ0=qGqo8jO)4
L]AJIA]Aq.%Xl5T<c=j2lW3Sk_?Ib7!URZM]AA91dd6`n=@K"B*aOp9c`Ho;M2VR`PDpk5S2@1I
0KS&7Ycs.WSHc,\U@I)Qoc[q?.@Y;3D(m>9V&6PZtCmG)C2:220m!/o-_D+ii_SOo:FiCR+c
sT'?"U'#SB:T?f_CjHB>563aiG9:&8B^LrEnrRH)J&'-PpKm4&2&.[km(,<@S0\Sf!RhS!aS
iNm,dDUUhb.dP2k\0j(7)2pIraE5OQDnUY3?&LpHbOHKS9_<kK*]A%.)qB2X?cVLT)GcAk3))
&-g_'L<A)V9h#,o&_o#%j7<;p39a^6Ps=:=2;n.To&.$H=_)9@Iq;gCfnF7RA&\;N'J,'eqE
OFc=aG#!T)Sm7&4n0&GBe'b4l]Aa2%:"XnXjg+4\`%!uo=Q;!A<s&Lt0i5l"=NVStl^FoZ`Oj
Zc<0>(5Q\K!gPMAV!V4U^6PEB5?sV9LaBU!ROi#-q'==XD)76GV,6l-BQT>P-e.1>FN2S)V)
PG?9V#X;h,u:S46&6s4)7>&'dk.C>#9n^iiL9-Kd59MIOb\kA&PCdY\h[EY@.PO<0Wl]AJdF9
#pYTI`b,IC[#m6%ck<"O7sT%.A?[[q+SC&2\4=)AVpRVXU&^mZXpAN+U^`4ZF7Wl]Ag:Iq6ZC
ecN0;[$Uqu>ejmLI+cB;!_qZkP\WH&13<l?)YlV)anW'C<7fqD%"Gm@XMouo"3T9[jA]AX)VN
4^mj=Q2auWr5&O%VSNVlg5,7tledB?+NW%U\N"ZGO+i-H<Wl">H@S5Al1nR30/RF%GB09aP>
ih+9W(@8SIhR0VEHuP(\nEQZYjXoBUlKCb2bXDG_$@8Ku>1=biR^Ddmf@W415reLcU>8;f+g
ilc;<mUdDPj1MsU1_]Aqn'j2Y*(16W:`BkiBc"hM$k21p\1m:T+M)XnOL`sUJ#XpjQH5+E&Hq
S6T.b7mhZh+*q.N??O^^)ag@&M%-(_Op.jgE'`QH&]A.Nf"SFo'*fH]Aj#]Aj]AFkq-13:o+O'lq
cO'J1B^R1ZV_A#:%X)&22Fl#6=j8=O+NFZV,b&:'\sapgJW=.7e0p1!Z\b29;-3"8FEop#Lm
E`c1uW*bA_@]A^g5r_NOlIT4T_ik9b;Gsu2&[l?1g1m.+:Ph]A!8f*[mdk@gk4&K4Lf+cBFD_F
cSniBY?NBQZ2I$!Q21P^sZ%/(.W3ilfMCZ33ksqYU03TZ]AOeK(tt`[0D(%&(:)P_=BM445+;
,Q)9#/d;Zlf.AXNWE\uOl*_2%R\g(N'$lVNm[l?FAce)_j`a2Ht/XW4\kS8e(e/kW#fut:L5
7Z`l05\09_rIc[mLJ;O<dbEl?s$E+>q6UboBWifGbTY`cWVW3qH7"jO0cd=^Ur=s6-[60nQb
pK=Rl51X"9qaC)qO=84?4%\WKU<i*>_rg+>NiJ,54\]A(?UAdB42D6jmb&e^:9c"T%!Y^%I"*
P^n/f6gS1\U8TP<>]ALN7VQ[4IG)ao'MaX:*5Or9j=#\aSg>HEQT4asr?^eS"S,t<ZP"R0Ci'
K%9Wp2)-r`;;.1@M1'D6g3?mqD<e9s0-Z0++QKe:M+s`]A.&FeaZE2FAp*%DL&K^b'S:V;-3;
3Ilo(B6"2k7>geGbj9I'2"UhohZ&a7.GVP-,R5.UdNDXJ.S`0im,E??tlMH>lWu/^X*^)gh.
=S(0.P<JKNc*79g3iX)ho?KdDW4(snGRR=/n91LV%B!D[(:c0/RH$^E,1g4)@bNa+!+Zq*0^
M.G$]AJrF&^t_cthK".c;1NgiVek3a1`XB8PO)h=^EV=YceoVW"?qb0;i[d]AR[GFKTMRG<`\m
6Vq!Z%+7qoS4]AJhc&WfQ22QW,KDo*'UGD&Hq"b@rem/B+5E^dQ+.G8=1rG(6GoqC5)]A%/_Im
@o$nc@1o&RWiKP=ATne4l-e87\&1A==tE!NUrajH$3ekg_ra7R@;9:tHj]A.5a_'NLg!f?@>O
JB=g4h=%$TPf_m"->N<!NrS@2bQ<:JR#_(:,*8$mO7A+3pD@!+^m]A4K'/Z]A-97>:_oZkDnI2
_*&:&;jtg3PJZ2`Ygk8m*;kNlNrSG/kb%80_HPX]A(A>?c0`FMW25@/D5T.NY)X7Y=SA<.dlR
qog,"1C@Kb5G!Xdf;<HLdeCpoMnF978.fc\S9F,9RcI.I/cK4$bIasupYe9g:Ofef]AW`TgWM
KMhX<o^#MZlo(,dQ6nj0)rF4Lqpi9;_n/,+E+W`9%YA?]AVYdSV1XaU@pL)Qdb+)klUqH3jJB
kF/]A<_(U4Q;HtYhEDsTN!Vq_VmDLLa\g/>5-2+#`_p9FM=8fdojD8j"$cAPEV%H<@B^[Nh2u
6F6C>5[<fO]A-.YKCHem.!3")?\:=@l,%j`6RU-;l@r1t^46YtWm8>mCQc(J9^VXM<(_"n;*4
Fg)WiYk%*YrR8XG3_HLj+am`/O^T'G0<q#(W)2#2;0FQP`mGZl_QlY8r(G>;%Br[U>3t6]AYF
*+C8W[+^(dm9q&'8KZ1E:55&8!'[7rm#.iNou'n'Tj35J!nR3"P1M/eCqBhr9%#PMHi=DGI,
\@6KG4sUCeR_Q>3d+d5">sh'KKiY=0*SYN$a.o(.jYGFRU"ZggZ;6bTY1)9OGI!V1&2K=tqU
(]Acd(kb%%_";(R.G5G(jU-:Htp7;rK41O@,>S2W9hg4.&!/PUC61V?uk)<95D!p[@A&UB?B4
l%QIc/p)j#m;O3sq!<f"Ifshh,%TT->N?KJaR/a&5Kc1OS/AD]ApdA''pE6A0$^]A);biO8smY
<Dau;iHE^QT5*_.^ZP*n=MK;:Yd8LJ_F3c/jr`/O9AWkpko,lX!t\K6IS_SfAG=a_>ee)heS
ORdkC$^lMi.M?D?h':_XOo2s`.4$U#uo/T=$X*Hr+,clYllI8T4IX.?eSKK]AE\b.j%"\(hH/
&/)#=D+Ek+&op22e,6->:\14@5L"\Hs"sairmUeCq+pUSk!.,jf9gLJ_rb=m?N/(pi@^_K&_
sC^\3!JhrpKDYaBc,r^jftn3V[[bkMX\&T7]A?5Ih)Gtr80V]AiNWX%j8DGVf?Q#W'C0EK7^rB
n56~
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
<BoundsAttr x="0" y="0" width="426" height="84"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="248" y="52" width="426" height="84"/>
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
<UUID uuid="0f3afe9f-97c6-4c5e-915a-b5743497f3ea"/>
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
<BoundsAttr x="0" y="0" width="257" height="105"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="695" y="172" width="257" height="105"/>
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
<UUID uuid="2a3a27e3-64ec-4173-b755-be55bd2234ae"/>
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
<BoundsAttr x="0" y="0" width="257" height="105"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="695" y="78" width="257" height="105"/>
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
<BoundsAttr x="245" y="141" width="267" height="20"/>
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
<WidgetName name="report3_c_c_c_c"/>
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
<WidgetName name="report3_c_c_c_c"/>
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
<O>
<![CDATA[年度线上销售同比]]></O>
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
<![CDATA[m?IKLdV0cCBq2'&`n]AosDQUqF3B:6&Ou@&]AWQ@f%;VH5m,DhCi2e>MdaU#,>XjdrB>e?pgUQ
(L!??3_*K%VIhMDJ\t&5g1F+Y%I<"T6+DT$H$(@"6ku:Z(@,I6Xp]Aj`s&9-hdlrb&Q7gFYFZ
V1&>:&!XuNk*<pREp8?6&s3M`Xh-dI(6.+Zg^V*l1-U.PI40lUorA`i1gC_a@\,T`"pr<!i$
id/C(-MS]AYV5oOhXK1#d=diM)nmH]ARpWM!\nL6ITDq0DIY!Q0roId4<sKOk+1h-dID>7<k3$
L\IcgQuQEFNW0Q?NE:6e6HJN+Aj(aCcWH81"cWGN\rC_^T>VG+]A@eZ._A@&u;I*T=V[W<JG)
QE?)*\b)"9L98YB*$M>L/SH*.D(<`/O:lk#D:q_`/%EpC332N^P"o$>K22]A1')=/?\Qu`%0P
7jB/.F9Lij"Ys:5Z"[Y`r4*\&T%M8+s@1&`_f&rd<2@%P<jI5sQeSc]AJub1C"'&@%iD<1tG'
$>K0`&<Rp!)i(Zj%D)1lG>'(-iJ;4qj\e=dp8,J?`CDha43,u.5\g"4gC8]ATZq@'q&-Fnj+^
lh`F3^[IhliFN*$3uHgqiXtaHLaa2So;P=I1nGiLM-V@Qa&qUca3O4UOFK6\d&@.Og,<AkDE
/13_]A5:ApstC$(VP2,Ya>@W$ZK!SGKqkSncIV#@=#EiVJ^Kb:\WHn]AnT6Z8/!22>j&=BBhbR
>[jK6AU5T\6LI&Mi[/L0I?K6,pPnF=^C!P@K)#T_=qlYuUV>(aSRA:&6=f1E<]A\p^X-aa#%_
^[?*c:L-qF=#O<3sMa2j(^RRHsf]A]AEcbWCcc3mUmuaTL*Y1u]Ag@V0e8o\%NM]A++kc^0-CF]AM
Uh'oB(X7G$@Q^^mq]Ae,p,DTCJGWmXouPQ?rP[h#&#k^3K!>[&(<1moTT;,A8uA02#Y]A_'J\R
V\h=CJo`XUI5Gq0HZEd+eq%&#Fo'Rptk?MH&24%`a'F363`6oL>P++[Lsp=Ws6IP"m?<Xdiu
WhP?H[AV:(2j4.Ym2FA^"M_i"BReFnKtgHo4lq5@M%_@STHK``nc\u!ILrpd.ec&H4h(ll=$
Bi-g`?<C`q9e:0r=;DP]A?pQ^fYKH7B_!ZfXaa^W=nYJ"%p<[:rV^foDr-llm%ToV?)U]A9:45
5T=^%3`=9Tf%L_7T(*>)T']A2r6qcWKX/X2$rRV#eLL5Rbr!UO%p(q4r^s_d[jp.>PZXIL`;<
L1<03))'TjQfSht=MR4\=SX?nMqbW9ug++Pji^VT<`\euJ=Mn$"jCF_I.X3O%%#(L'h!_f$h
=c5ZUNZRS*Tn3':Zpco0^V>p?=1j%p:gRg'=#L5S*A.bB;k"E9pgpj$3W$G]A1hnj`k!cX0^O
E#!qjHOA?"[BX&j*Yh,\#QAPE4(;!cW+3o-'\X3L*%.j!&C5kPFW/+([kBn"C3)6+VVB'R>c
f$KQRIR7oQ+heAd1EYT[c"d)t,motgQU8R!?Cue!/#t&mk1%&_%Y())gW5HTJY.hQfg*ja%V
\HW>4.\Pr(4$?G<1pK]AaMNac?N-IjqKf7%$q)+YKk_Vm)9I#1L-2l[_q(HF0G/Z56OPLU5p<
5*@D0ZNN\Ste+gtq3Tj/o+e<F/Z^.c*T1&G\\b)V-&omQ?p%4Mke'N%)K?U,,_"a&iYh<:pZ
iQbhbs)g%a8(:aoia#`WmMDN<SiA!kfrM7lN7oJ*$7qOe/fXG[!`L`^06cI0*WNEUVh;"At^
fK&):aNVp]Ap,G;G5]A.SG'p1bsK6PM7@Qe;1Y7PC?31K,)r.D!umITjPlmTcCU#X_UMXk^>o>
SS0WQ9^l[`\5GpSSsCjSb=,j2#0I.'/1ar\&4%j-q`P08!Y7/]AP?M[l5=XC7G`H`/iK='X]A'
\MA$*"^KFu)qME2!LhZiP9M5tmMJ?C\aK!t(0!K(<;:^V44:=^$XLpB*\<%d$bi!9<WDY'Mq
$Y[G_ab>SpL"D*.2"H6/TT5fFa'kCF4N9YVPKjj&Q8P,Z592:Z,M<[*I37Ml?dkH&J0.%XV!
/%Y_V,]Ai:qfQ:O3]AjDo>Oa^fMOR#OC>0A5jkdH'n@f`dF2JVk`bppF]Agm.$4kA?27k6OfKmV
#k[dVM,iH6gj66R%0+V[6d'LErW66R%0+V[6d'LErW66R%0+nU8;k#en$%JJVMK%0VhS$$UC
T\K.BQkdbbVd6EQA<-_IOSF;PY.KF"LY[!p<8"A:#ZQ')2p'\O!r~
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
<BoundsAttr x="245" y="360" width="267" height="20"/>
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
<Attr enable="false" duration="4" followMouse="false" showMutiSeries="true" isCustom="false"/>
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
<UUID uuid="f1a21915-7346-46fd-a927-58d58f12ce74"/>
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
<BoundsAttr x="0" y="0" width="397" height="197"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="255" y="169" width="397" height="197"/>
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
<Attr enable="true" duration="4" followMouse="true" showMutiSeries="true" isCustom="false"/>
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
<UUID uuid="ca8aae0b-1b87-40e4-95f9-28c64451872c"/>
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
<BoundsAttr x="0" y="0" width="222" height="294"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="10" y="58" width="222" height="294"/>
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
<InnerWidget class="com.fr.form.ui.container.WAbsoluteLayout">
<WidgetName name="absolute50"/>
<WidgetID widgetID="ed256e8a-61e0-4974-a5f1-38228a804fb3"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="1.组件推荐尺寸为 250*160；
2.柱形图和折线图分别使用不同的Y轴；
3.柱形图系列2渐变色在条件属性中设置。">
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
<ExtendSharableAttrMark class="com.fr.base.iofile.attr.ExtendSharableAttrMark">
<ExtendSharableAttrMark shareId="b7d66ba1-2a51-4640-a50e-2869694b748a"/>
</ExtendSharableAttrMark>
<SharableAttrMark class="com.fr.base.iofile.attr.SharableAttrMark">
<SharableAttrMark isShared="true"/>
</SharableAttrMark>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="chart00"/>
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
<WidgetName name="chart00"/>
<WidgetID widgetID="0b781cf9-6e32-4fbb-ac48-a5b78985c4d4"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
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
<![CDATA[新建图表标题]]></O>
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
<Attr position="1" visible="true" themed="false"/>
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-5711111" hor="-1" ver="-1"/>
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
<FRFont name="SimSun" style="0" size="72"/>
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
<FineColor color="-16678475" hor="-1" ver="-1"/>
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
<newLineColor themed="false">
<lineColor>
<FineColor color="-16364659" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="3"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-5711111" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=1"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="X轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList/>
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
<newAxisAttr isShowAxisLabel="true"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="false" mainGridPredefinedStyle="false">
<mainGridColor>
<FineColor color="-16239769" hor="-1" ver="-1"/>
</mainGridColor>
<lineColor>
<FineColor color="-16364659" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="2"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-5711111" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=1"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="dashed"/>
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
<AxisPosition value="4"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="88">
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
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴2" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
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
<Attr lineStyle="0" isRoundBorder="false" roundRadius="5"/>
<newColor autoColor="false" themed="false">
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
<FRFont name="宋体" style="0" size="72">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="72">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
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
<HtmlLabel customText="function(){ return this.value + &quot;万&quot;;}" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
</labelDetail>
</AttrLabel>
</Attr>
<Attr class="com.fr.plugin.chart.base.AttrTooltip">
<AttrTooltip>
<Attr enable="false" duration="4" followMouse="false" showMutiSeries="true" isCustom="false"/>
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
</AttrList>
</ConditionAttr>
</DefaultAttr>
<ConditionAttrList>
<List index="0">
<ConditionAttr name="系列2渐变色">
<AttrList>
<Attr class="com.fr.chart.base.AttrBackground">
<AttrBackground>
<Background name="ColorBackground"/>
<Attr gradientType="custom" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-13477774" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-3479565" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
</Attr>
</AttrList>
<Condition class="com.fr.chart.chartattr.ChartCommonCondition">
<CNUMBER>
<![CDATA[2]]></CNUMBER>
<CNAME>
<![CDATA[SERIES_INDEX]]></CNAME>
<Compare op="0">
<O>
<![CDATA[2]]></O>
</Compare>
</Condition>
</ConditionAttr>
</List>
</ConditionAttrList>
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
<Attr position="4" visible="true" themed="false"/>
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
<Attr gradientType="custom">
<startColor>
<FineColor color="-14658974" hor="-1" ver="-1"/>
</startColor>
<endColor>
<FineColor color="-16647751" hor="-1" ver="-1"/>
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
<newLineColor themed="false">
<lineColor>
<FineColor color="-16364659" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="3"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-5711111" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=1"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="X轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList/>
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
<newAxisAttr isShowAxisLabel="true"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="false" mainGridPredefinedStyle="false">
<mainGridColor>
<FineColor color="-16239769" hor="-1" ver="-1"/>
</mainGridColor>
<lineColor>
<FineColor color="-16364659" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="2"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-5711111" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=1"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="dashed"/>
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
<AxisPosition value="4"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="88">
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
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴2" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
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
<Attr xAxisIndex="0" yAxisIndex="0" stacked="false" percentStacked="false" stackID="stackID"/>
</AttrSeriesStackAndAxis>
</Attr>
</AttrList>
<Condition class="com.fr.data.condition.ListCondition"/>
</ConditionAttr>
</List>
</ConditionAttrList>
</ConditionCollection>
</stackAndAxisCondition>
<VanChartColumnPlotAttr seriesOverlapPercent="20.0" categoryIntervalPercent="20.0" fixedWidth="true" columnWidth="5" filledWithImage="false" isBar="false"/>
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
<Attr class="com.fr.plugin.chart.base.VanChartAttrLine">
<VanAttrLine>
<Attr lineType="solid" lineWidth="2.0" lineStyle="2" nullValueBreak="true"/>
</VanAttrLine>
</Attr>
<Attr class="com.fr.plugin.chart.base.VanChartAttrMarker">
<VanAttrMarker>
<Attr isCommon="true" anchorSize="22.0" markerType="RoundMarker" radius="2.5" width="30.0" height="30.0"/>
<Background name="NullBackground"/>
</VanAttrMarker>
</Attr>
<Attr class="com.fr.plugin.chart.base.AttrLabel">
<AttrLabel>
<labelAttr enable="false"/>
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
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="宋体" style="0" size="72"/>
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
<Attr class="com.fr.plugin.chart.base.AttrTooltip">
<AttrTooltip>
<Attr enable="false" duration="4" followMouse="false" showMutiSeries="true" isCustom="false"/>
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
<Attr position="4" visible="true" themed="false"/>
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
<newLineColor themed="false">
<lineColor>
<FineColor color="-16364659" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="3"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-5711111" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=1"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="X轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList/>
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
<newAxisAttr isShowAxisLabel="true"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="false" mainGridPredefinedStyle="false">
<mainGridColor>
<FineColor color="-16239769" hor="-1" ver="-1"/>
</mainGridColor>
<lineColor>
<FineColor color="-16364659" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="2"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-5711111" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=1"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="dashed"/>
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
<AxisPosition value="4"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="88">
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
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴2" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
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
<Attr xAxisIndex="0" yAxisIndex="1" stacked="false" percentStacked="false" stackID="stackID"/>
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
<MoreNameCDDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<TableData class="com.fr.data.impl.NameTableData">
<Name>
<![CDATA[同比分析]]></Name>
</TableData>
<CategoryName value="月份"/>
<ChartSummaryColumn name="2024年" function="com.fr.data.util.function.SumFunction" customName="2024年"/>
</MoreNameCDDefinition>
</DefinitionMap>
<DefinitionMap key="line">
<NormalReportDataDefinition>
<Category>
<O>
<![CDATA[]]></O>
</Category>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
</NormalReportDataDefinition>
</DefinitionMap>
</DefinitionMapList>
</CustomDefinition>
</ChartDefinition>
</Chart>
<UUID uuid="2bbf4025-086e-49d4-985d-7c7f6e63c6df"/>
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
<BoundsAttr x="0" y="0" width="371" height="115"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="29" y="38" width="371" height="115"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
<Sorted sorted="false"/>
<MobileWidgetList>
<Widget widgetName="chart00"/>
</MobileWidgetList>
<FrozenWidgets/>
<MobileBookMarkStyle class="com.fr.form.ui.mobile.impl.DefaultMobileBookMarkStyle"/>
<WidgetScalingAttr compState="0"/>
</InnerWidget>
<BoundsAttr x="235" y="373" width="446" height="156"/>
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
	$("div[widgetname=REPORT3_C]A").find(".reportContent")[0]A.style.overflow="hidden"
},100);]]></Content>
</JavaScript>
</Listener>
<WidgetName name="report3_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report3_c" frozen="false"/>
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
<WidgetName name="report3_c"/>
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
<![CDATA[396240,4084320,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
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
<![CDATA[= MONTH(DATEDELTA(TODAY(),-1))+ "月品类销售占比"]]></Attributes>
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
<![CDATA[mF-P=RqE]A@nCOb2f&^q[1G'he4*S7M2m1:HBe;era&l!TK\]AhWK%.@Ykp>=ZY=6o<(=Wu'Z'
2^6NVM$s,h]A#rdn+B!OOT>9;:1RuaN9A<RQ(6'^\_O0?gmT6TDLb.kPIC!\)t$X"OnUP6N@+
ZLl$dA!&tMq!:CXdhV*n;\o[fN^e[EFS@_&Ll/tOg_)-WZaBdU/QF-[<d*"6<_W+UVb'OSB=
^3XHOET80QuN),YFpqYrJ>1bEIl`P5N<f=\1tY0n&B]A_K:+oV5OM-&Gcq0<UE7j\mJ:7]A4'G
1==LmCLQ#t6-Sg5dgHN&"AHuN[N3KVGPZ1HesYO6-kP2"jknWifZn)]A$@?IgPko/#s$%![EA
Q66Wb___V$05f$DiQ0rT*&2jIXnA5\)sLlQfSdh>MN0!Fg5:fbR4VtX\ZF47r=f"IEm!bhUQ
hTc=ZUI>bA=]ArIB3cO6)X3$D<g!AfqrK;b<jCu@)WGGkHUgA>cG'0)h]A*NB839No5ZZ)l.U`
8RQkH/BC;/d!`ee$XNmj2B3/-u7+^pe8^f9\2uASW25Ufioj,T@I).W4]A\X^n<NOPkbluIK6
/Qsc_,Z(6]Am[G1h@[Z$Qe9=EqIQf!8-#!6@H2/:,76K.KXsDjQ%C*2c8Ri_jMLOmm3(9=OcW
))Q;F!N(M9t69p5I&"?p=@G]AX;57[rWhNJePEVMB)NP/:]A3OkSqIW:s.n>IA<kO_Og-:AQ#,
ZC,EMbb#_H&K<]AuK!jZZr.IUT,4X;O#PYFG5TG[h^tlN#^F@KaK\q9=pEtgo*%3iD>oa`uE2
d2]AmU1_Nj@I1+nb!1N.>i?N15)cV_\M\u;shb5a=;d2=6aa.&Y?R:C,XWsk?mR6USKn4aul7
]As(7X=AWVf/B5>,EN\I`;;EOOJYj5#ek%1e:-B>=ULacp3Hr\7C!>:=AU)j*Y3=bbgc)o2lI
*'YB(l/p@3mFFcnr(S"!YL0Re1Ze$*i(qKM)=.*m>>P1QDt!WFM)nDW1I\NEO.A#(n<9296A
oKV=/`$j8<?_eiSG%>H.M2@o#Q3nPQa<gT.4J4kKdAa0+[rGK`^>k#T'uhms/'e+6&,GdN9[
8K,]A]AV&k?K5714&Z;W]AojXN8iPnBH4XQ".i-2)KN4B<8(@Pu9DMFNT`['!D+G1]AjaajPnp\b
]AFZ;Y3hL&i8HJl=XXV)o\?UO,5P1?NPF#BF;Iljf.Y979'DZ0&KP5f%=u:Y4`CaCg!(8TWuU
S)Q*S,/Nb.7QbqJX18dpJ(Hb6iEAc;",gMnK2f52CpMuO%c>gNMnB:fZ]AcZHQCu?R*&W0D<+
r$^V74:J7MGSsM'VPe$-peN':k\fikr'cTRcm)=:3+V^%j$h(k#.P%Y.\iXpG4Yo@q60Sr!s
Pr>0;?ml+;fU$QLG3-PLgcE\%.j~
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
<BoundsAttr x="0" y="0" width="200" height="20"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="10" y="359" width="200" height="20"/>
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
<WidgetName name="chart1"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
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
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__C98B628C9FADB557B41820A512057ACB">
<IM>
<![CDATA[lO<9(kN.ld@UNU%p%320@UNTh?smA_iEubF,kJ>a!K*4i\i>FDb^"P`UT[@aKNk*GPNj?(F'
%3KL9`fLg^8UkQdSb_QE`tPZ5I_^oX$7,Gjjjd#CE&@cN!W.md0*T(']AKq'o1Ink'_Jq]At!4
>JaTjIGJ??>p>o!X'*H.39/!IHoWYpbVl0:eBa%>\CoP$I9Y:cB$)Y=,pSBEc]A.WR.[)[)&)
&TfMlmht3FlAe*0-KGnIcUr&`C_[Z$k*Ut%a5=i*<JK]A1C/T>.QB![.WOE$@:3d,BE\0"5]AJ
J,Y*70#T6<EIE;d8bmD':3@CGok\'>Qel$GNph)q]A^<:QpH;8o;f7hq(7*`Y>&GZ6Ct'S!L%
d.^jqg!N#Uje]ArU'#9OKL\U/hM>eXb#8Doe5Nd*)kqX"L%V/$2]A/&rKm'f_2IC_q'+5!Cr?6
&>B11cI"p2e]A.[K(Y?AX<(@rM'fp0<Y8$*+VOUSqfRoU#I$3\IFZO-^NYZ%cf?h]A)&t=F%U*
I!!~
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
<Plot class="com.fr.plugin.chart.PiePlot4VanChart">
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
<FineColor color="-1118482" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isNullValueBreak="true" autoRefreshPerSecond="3" seriesDragEnable="false" plotStyle="0" combinedSize="50.0"/>
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
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-1" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
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
<Attr content="&lt;p style=&quot;text-align: left;&quot;&gt;&lt;img data-id=&quot;${SERIES}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${SERIES}${VALUE}"/>
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
<Attr showLine="true" isHorizontal="true" autoAdjust="false" position="6" align="9" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="宋体" style="0" size="72"/>
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
<HtmlLabel customText="function(){ return this.seriesName+this.value+this.percentage;}" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
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
<Attr showLine="false" isHorizontal="true" autoAdjust="false" position="3" align="9" isCustom="true"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="80">
<foreground>
<FineColor color="-13421773" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<PieCategoryLabelContent>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="80">
<foreground>
<FineColor color="-13421773" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: center;&quot;&gt;&lt;img data-id=&quot;${CATEGORY}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${CATEGORY}"/>
</AttrTooltipRichText>
</richText>
<richTextSummaryValue class="com.fr.plugin.chart.base.format.AttrTooltipSummaryValueFormat">
<AttrTooltipSummaryValueFormat>
<Attr enable="false"/>
</AttrTooltipSummaryValueFormat>
</richTextSummaryValue>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="true" isRichText="false" richTextAlign="center" showAllSeries="false"/>
<summaryValue class="com.fr.plugin.chart.base.format.AttrTooltipSummaryValueFormat">
<AttrTooltipSummaryValueFormat>
<Attr enable="false"/>
</AttrTooltipSummaryValueFormat>
</summaryValue>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</category>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
</PieCategoryLabelContent>
</gaugeValueLabel>
</AttrLabel>
</Attr>
</AttrList>
</ConditionAttr>
</DefaultAttr>
<ConditionAttrList>
<List index="0">
<ConditionAttr name="条件属性1">
<AttrList>
<Attr class="com.fr.plugin.chart.base.AttrEffect">
<AttrEffect>
<attr enabled="true" period="2.0"/>
</AttrEffect>
</Attr>
</AttrList>
<Condition class="com.fr.chart.chartattr.ChartCommonCondition">
<CNUMBER>
<![CDATA[4]]></CNUMBER>
<CNAME>
<![CDATA[VALUE]]></CNAME>
<Compare op="2">
<O>
<![CDATA[0]]></O>
</Compare>
</Condition>
</ConditionAttr>
</List>
</ConditionAttrList>
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
<FRFont name="微软雅黑" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
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
<FRFont name="SimSun" style="0" size="72"/>
</DataSheet>
<DataProcessor class="com.fr.base.chart.chartdata.model.NormalDataModel"/>
<newPlotFillStyle>
<AttrFillStyle>
<AFStyle colorStyle="1"/>
<FillStyleName fillStyleName="新特性"/>
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
<Attr gradientType="normal">
<startColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</startColor>
<endColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</endColor>
</Attr>
</GradientStyle>
<PieAttr4VanChart roseType="normal" startAngle="0.0" endAngle="360.0" innerRadius="65.0" supportRotation="false"/>
<VanChartRadius radiusType="fixed" radius="50"/>
</Plot>
<ChartDefinition>
<OneValueCDDefinition seriesName="分类" valueName="总金额" function="com.fr.plugin.chart.base.FirstFunction">
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<TableData class="com.fr.data.impl.NameTableData">
<Name>
<![CDATA[月度各品类销售额]]></Name>
</TableData>
<CategoryName value="无"/>
</OneValueCDDefinition>
</ChartDefinition>
</Chart>
<UUID uuid="e42aaacc-9849-4aa2-9ffb-177fb76ffeb1"/>
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
<Attr alignText="0" themed="false">
<FRFont name="SimSun" style="0" size="72"/>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="SimSun" style="0" size="72"/>
</Attr>
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
<BoundsAttr x="0" y="0" width="222" height="151"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="10" y="382" width="222" height="151"/>
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
<BoundsAttr x="0" y="0" width="446" height="202"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="230" y="157" width="446" height="202"/>
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
<BoundsAttr x="0" y="0" width="446" height="150"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="230" y="382" width="446" height="150"/>
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
<BoundsAttr x="0" y="0" width="273" height="200"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="679" y="67" width="273" height="200"/>
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
<Widget widgetName="report00"/>
<Widget widgetName="chart000"/>
<Widget widgetName="report4_c_c_c_c_c"/>
<Widget widgetName="chart0000"/>
<Widget widgetName="report3_c_c_c_c_c"/>
<Widget widgetName="report4"/>
<Widget widgetName="chart01"/>
<Widget widgetName="chart0000_c"/>
<Widget widgetName="report3_c"/>
<Widget widgetName="report3_c_c_c_c"/>
<Widget widgetName="absolute50"/>
<Widget widgetName="chart1"/>
<Widget widgetName="report4_c_c"/>
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
<StrategyConfig dsName="BI2024总销售额" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
</StrategyConfigs>
</StrategyConfigsAttr>
<NewFormMarkAttr class="com.fr.form.fit.NewFormMarkAttr">
<NewFormMarkAttr type="1" tabPreload="true" fontScaleFrontAdjust="true" supportColRowAutoAdjust="true" supportExportTransparency="false"/>
</NewFormMarkAttr>
<TemplateIdAttMark class="com.fr.base.iofile.attr.TemplateIdAttrMark">
<TemplateIdAttMark TemplateId="31dc8673-ef37-4837-8e01-4fc1dbdb3446"/>
</TemplateIdAttMark>
</Form>
