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
and 渠道 not regexp '样品|dg' 
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
<![CDATA[select round(sum(ifnull(实付金额,0)),2)  总金额 from  
profit.dw_吉客云销售明细单  
where 公司 regexp '深圳' and 部门 not regexp '私域|线下|分销' 
and  left(发货时间,7) = date_format((CURDATE() - INTERVAL 1 DAY),'%Y-%m')  
and 渠道 not regexp '样品|dg'
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
,round((sum(含税单价*销量))/10,2) 成本
,round((sum(ifnull(实付金额,0)))/10 ,2)  金额
,(round((sum(ifnull(实付金额,0)))/10 ,2)) - (round((sum(含税单价*销量))/10,2)) 毛利

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
<![CDATA[select round(sum(ifnull(实付金额,0)),2)  总金额 from  
profit.dw_吉客云销售明细单  
where 公司 regexp '深圳' and 部门 not regexp '私域|线下|分销' 
and 发货时间 =  DATE(DATE_SUB(CURDATE(), INTERVAL 1 DAY))  
and 渠道 not regexp '样品|dg' 
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
and 渠道 not regexp '样品|dg' 
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
<![CDATA[select round(sum(ifnull(实付金额,0)),2)  总金额 from  
profit.dw_吉客云销售明细单  
where 公司 regexp '深圳' and 部门 not regexp '私域|线下|分销' and 发货时间 like '2024%'  and 渠道 not regexp '样品|dg' 
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
<![CDATA[

with a as (
select round((sum(ifnull(实付金额,0)))/10000,2) as '2024年',concat(month(发货时间),'月') 月份 from  
profit.dw_吉客云销售明细单  
where 公司 regexp '深圳' and 部门 
not regexp '私域|线下|分销' 
and 渠道 not regexp '样品|dg' 
and 发货时间 like '2024%'
and 实付金额 > 0 
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
,round((sum(含税单价*销量))/10,2) 成本
,round((sum(ifnull(实付金额,0)))/10 ,2)  金额
,(round((sum(ifnull(实付金额,0)))/10 ,2)) - (round((sum(含税单价*销量))/10,2)) 毛利

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
<TableData name="月维度线下分销业务员目标达成" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[with a as (
select 
实付金额 ,销售人员,left(发货时间,7) 发货时间,渠道
from  profit.dw_吉客云销售明细单 
where 公司 regexp '深圳' and 部门  regexp '线下|分销' 
and  left(发货时间,7) =  date_format((CURDATE() - INTERVAL 1 DAY),'%Y-%m') 
and 渠道 not regexp '样品|dg' 
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分'
)

,aa as (
select round(sum(实付金额) ,2) 销售额 ,
case 
	when 销售人员 regexp '钟意珍|陈玉' then '钟意珍_陈玉' else 销售人员
end
销售人员,发货时间 from a 
group by 发货时间,case 
	when 销售人员 regexp '钟意珍|陈玉' then '钟意珍_陈玉' else 销售人员
end

)



,b as (
select 实付金额,
case when bb.业务员 is not null then  bb.业务员 else  a.销售人员 end  
销售人员,发货时间,渠道 from a  left join
(select * from profit.人工导入bi线下业务员渠道关系 group by 销售渠道) bb
on substring_index(a.渠道,'-sz',1) = bb.销售渠道
where bb.业务员 is not null 
)

,c as (
select round(sum(实付金额),2) 销售额 ,销售人员,发货时间 from b
group by b.销售人员,b.发货时间)


select 发货时间,销售人员,销售额,目标额,销售额/目标额 达成率 from c left join 
(select round(目标额,2)目标额,业务员 ,日期 from profit.人工导入bi线下业务员目标) cc
on c.销售人员 = cc.业务员 and c.发货时间 = cc.日期
where cc.业务员 is not null 

union all 

select 发货时间,aa.销售人员,aa.销售额,目标额,销售额/目标额 达成率 from aa 
left join 
(select * from profit.人工导入bi分销业务员目标) aaa
on aa.销售人员 =aaa.销售人员 and  aa.发货时间 = aaa.日期
where aaa.销售人员 is not null 

order by 销售额 desc]]></Query>
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
<UUID uuid="26e58997-b422-4327-893a-55a954e73a50"/>
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
<BoundsAttr x="0" y="0" width="257" height="105"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="695" y="171" width="257" height="105"/>
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
<UUID uuid="8739de02-b420-445a-acb3-437743011d23"/>
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
<BoundsAttr x="0" y="0" width="257" height="105"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="695" y="78" width="257" height="105"/>
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
<BoundsAttr x="0" y="0" width="273" height="209"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="679" y="67" width="273" height="209"/>
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
<ConditionAttrList>
<List index="0">
<ConditionAttr name="条件属性1">
<AttrList>
<Attr class="com.fr.plugin.chart.base.AttrEffect">
<AttrEffect>
<attr enabled="true" period="1.0"/>
</AttrEffect>
</Attr>
</AttrList>
<Condition class="com.fr.chart.chartattr.ChartCommonCondition">
<CNUMBER>
<![CDATA[1]]></CNUMBER>
<CNAME>
<![CDATA[CATEGORY_NAME]]></CNAME>
<Compare op="0">
<O>
<![CDATA[抖音旗舰]]></O>
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
<UUID uuid="0cf8db20-ad7d-4a6b-bff3-e369a188c733"/>
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
<BoundsAttr x="0" y="0" width="397" height="197"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="255" y="169" width="397" height="197"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WAbsoluteLayout">
<WidgetName name="absolute10"/>
<WidgetID widgetID="cf636775-5857-477c-92e2-48bd0b63e995"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="1.单个报表块推荐尺寸为110*77；
2.组件底层叠加了一个不透明背景，可删除使用。">
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
<ExtendSharableAttrMark shareId="b7e51af1-a2b7-4cfe-ba50-5c6db3a78baf"/>
</ExtendSharableAttrMark>
<SharableAttrMark class="com.fr.base.iofile.attr.SharableAttrMark">
<SharableAttrMark isShared="true"/>
</SharableAttrMark>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="report30_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
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
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report30_c"/>
<WidgetID widgetID="06bae1b9-86d5-43d0-8389-21d71a3ea643"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-16636871" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__81564603BBD4F6BE6C196F5CB7615F86">
<IM>
<![CDATA[Uq9QEAPq%_)V_]A;-R\33Fum'S@N-?B7`SQ%=<5"`VdnJmrVa;\p[)!u<inN#bu%u13Td?q5?
*lCOV%j1^qdaIAS!.:rnU*ES\O)jr`t$MPSet&GsoeILh_1rT)6Fj?nFT+1(ckW>MpiO@#=m
&p`0n4>Q2!`NJ<H'N@c;fhq4M\KP/:>TjrC$'rl"\^b:1+2T9,fG4d/'QcId<a@N#5P\`O)f
/5@p\X<VIb'i"5S^%m^L*FZPN07^,7?>h6UA4ce3%lW]A,76/9iUT=8ql(c_b=Z>-P_(Wd#Mu
/0ZZddoI84_HLIGN0*^c#_$E%M$a5OJn;1,`3P3DT7qsTHL68@GkWMWX0d_e!]A)qEFeY>V0I
B-MZtl_iVF$/.L3an)!]AUpjfAn&:@FU-ng,j2LKR(5Dp$j`9;DFg3L-Yf]AmC1&(Y]Al9.HT@;
q8q-/b-pld1<na.R.jW6:,i@o:WTCFV)-h:TpaY87X;AXefW!U,,Zjk-N++Z'grk=]Afn\ST;
W+KUc!6[l_\N2MEA%6B5K.qfUuZP1X+OR0kS_,-$>A]AN>NNGV0%:=dg%l["mEj,r=B;f+E.a
FJ`+r>UQ.a=Y`CGo)*06)9BaB?desWhp`)J@L96<]AT-DQ]A+bRO*s8o+OS4HN`gcJ,+]A2_&9"
?0A"rO*a@N:^9;=(u2E'"`Cp5#`FkUjK-`>s%f1..J#JqX1Puf6c.WNhaSedG"9@.<b@.*Cs
d3b6-N*,)]A7KJtgs+G)R"InSreU3u5EGqDD+h&X/<CI@dc/Ucr9JZTijJS-WjRP'nmOJ\PHP
5kbQAgQ(:k??a*eP!<RhU!)m1T(2Db1+MPF:q`Kdi$KboenFP";mrQBf["=`l7WjgeOK!FA,
e"*oD(\W*:Bb`[?)U@tK5HtBN'ps9&AqGJ?Q@Y\eXl4-qt>8IK5bp6R/Yp=S'Jss:Wkh$`(;
J)Dn$$UnM@0,CNAqK[<#-:d5h&6@"KSJF#kb7jBABaDr'EV=cb;r9W124mU`P//Qr.SbqP+3
8_>IH#($S+kDMnPR\XlkN!Nj7C%5sjPBGF5g@82I9c5mP%,7N!"g#Y-Tj.8^=.>DV%,&gTIg
2KWJ=9YhY3(.Kp'+&"Kobp(]AV0,U;]AFO;o'8imd,e!M)<U:6eLe#KpDJj1Xt#V(<b$h?^(\C
ea1O;B*aQR\^dE3WV@Sg+Dg:_$!M$h'8u[%cHm.]A<F,P4#Zn[3>Ck2f%tA_WFIa%I!Lp@A]Af
".e]AAn<FHC(cBaZ&9`9(':M$Hheme'a1enmH_C#%3?Rn?a2T:h61<&'gq/V?"`#g_<h/6dEL
e2EML*K'6aDD]AK$$Z?q<1P8+M&]ACHBJ[c9KS.9-0F:oU4$FffntQQbU^9d36J6iQPKig#QH$
<)-V7h0p<W+bK:ZtFaCSpuR,T83graB[Paa/n8I$YbM2NE:ea'0n>30;E_`Y/?-rt:C,h87F
.$6T-8WaoQ-?(mF[W^+4GEUAJUfC_@_9CDLq%k$]AdoI5En:!m,.mAP`5OQCFlJni&-f;83_c
ep?N8[+ZN2="/C)%LSe1PUJ6.=$fiaF3W'F2_]ACuDl>^9J%jobmTC[)V?.O.EUj4%$\4Zs9F
GL\K4oCNbA[\sH%^^6Rj0c'Cldhq+%)`K9uTAYa]AqfFp<t>i%g'k\_!c.m#O;GS8#AC.fV0q
,bagoX#O;YY1Ws_DQMhiZ^6Qm#i*"c6pZMU%iOEfNXDCI7Sr[\PFZEN<YkAiC'?]AUsuLU@:;
9)!r#9+%H4"NLcg'q=]Ag9o-.A&c+P^-Z3j[0"e0InK<CS0^D-Sos$JB6/^?m%WGlkpO*PS<]A
A3'&c_)'!aYq&3V)C3.!bXqOgJ.6`;;U@<0(7c?m24)pV`*khI=5Pj**P]Aq[:!ui"[rU"r>!
OO]A'r/f)aI;Mdqt)XI3:j)8fZnD7j@5M%"#TX'%<W&]Aa:&tqh=;f]A%`H[Q[NJomLp$:^9>fC
_4!D]A!KGiK*K5rJeNTlBXnVVrfKu8!@>%#rc3tjU#$5Q!/%C#blOb?f&20Xkafckml'l$BPM
cXkQW.Ud(F`p.8Tc@,g?dkCLH[ui;PomG;LJ^pT0:amY"1ZJhW\-Zh,m3uoU%Y5&0m83_=k8
L0(X>l[<s7&keCF69`ATAaMF[dh7'4JV3jWJ\$!oFHB#?Wnj9`2W8rUGSTT=oGhu3[s-X-7U
oI]A72I5A?G'g$o_Jpf*YPTR>o65b?Xk*8<HM05qC`h'@Qm,T&_TpQ?&!sCBbGZJ\nrb'c6ht
:>_pR`C5)T'BBN?QnM06T\WfgY*KY:=%edF4-2GHshdRXA1)\Yqj/-BZ[["[.prCg=pP2:/K
"L+OB$3*Ta).qQ?QqF?UlYu/GJQK6Ci7_11gr/tcq(;th-S4LE:[jEg#EA)73FD/Vs.^,/XF
.I)6,2hf5bm)OTdr=b_pFI6OpkZ;O%36jnh'i)4?Nd-^>$\A\m8:#%A<2g%3%pT^dT<S\)qY
*=:F;MffKj+Pq&V]A^Ni/G\f3&iUqf9gZMt[(ZWB@SDb/!1JVhH%5!>3L5<_!>Z!BZ60OK"Lu
8VWC(\)lRVV^<=3;>'/dh*1?Gq7\f/I`I<5a"=L^M`N9<e4qBFDKZM.B<<?]A)`9q*8uS:Kfi
do8OSn9LDQf]A8fWHimN-#P:OkGuIGApRK'iCc#$m7gpr\Wr9qH?=&NqKsJa)=D*fO0raS$$$
1Hrh55U3+7!D?$GV]A3_0Y3EG^id)C?H.2q`'8o-"V:D.'tLj]AsJ1(]A(c*#Yu,-N8Z)ZubK-_
b^'p\c[g<f5_^Oh;c6KmPT^09!\c7T?-TjgOEc.pL@1\Zru]AAQ62o5L*aHflnGnon)^p%E)O
VQD32;S(u(9.cUZ4?>+`o+oHNBsWkZ?Mdb"jf0;A=4(;hDH;Jr)A1Bd1;q1937VO-S(J-_BB
IJ7`e@JCTtAJ+\[cf4es%&sq*3I9J*'X+!%%g>DboZh-ahh!#TN6GN7]AHb$@.tc.GHW<Q7!j
;317Zo;%H_QC'4A4UF+muNJ[6/,8FO=rdQ.3$UP#n'&DXNPkgY6Y3hJY>L?[h)Kk+3>:7(=9
*:PM_*r]Ak,B/'(Bl6"bS+Fpa:aMr[^)5\tj8he"XEj0F%1Ag=4%!hu:1os6GJO9/S.?Q-5:T
3&o-f5'2*!7=7!1TpVQHi9CrhaWdP%F[A0p>Y18JZ1(X##"q^2G?80F/&VEj.ZFWr.lY;V2e
ok9hq9GSdSJ`Tgd=M\8-ZD+K+J;/9,feN7\V_+Bk"bkC%,`/pOqU!T(F)H"?Zs&Q+tUp&U`E
L9fLjBDRC]AM7UL2J)O^Dr-A#qFa"J]A6`oV5Dm$k[k$tib[K&FS*bEcLXCaKYc<e#<Snd?aOT
+r18,]AV2gt=#-l<:+nNVh&6M/]AYa$Nta#m0E.`214pNY.YlHI1L5>*,uAUI7o0`I]Aj(Y?m;K
Z.PCK>_VW^r,EtmH)#aI%/UEKmXbAbDnsJ]A":9?Xe\NuJPi>O6KKMC't@D2,hA>[rldDO4oh
3+[170#5n("$86."0*jOGm]A5[3k.]ACaRKa\((G6pWdh.`DZ_9^[0\&/"Btpnp*^s]A@BudTl0
D,K1B$^*CY3l09+"JZ*j8^(gt8#^J@$<3f]A2#N9OtP[uSe7VPab`\!Eb#rdM\2$eIs&?+=KC
X)5kg:L*ZG:-RP\c:gk>Kb802$1e':=7Z6_\:43?1Qgkrg`_/_RFY%!m-uDnj@e'KrLl`[T@
!%ga(]A$5KI]AOM\$)egUqFpD\mn'Xf".,J,7n'(-O3&XbVTEBj<f.]AN@1f=\9W!WpASlj-c=!
G(5&9V9A0Y!^b9qCUSXVGZQZXPf6=a.)idiFGKrP[<o<M(%E^t,/:aYLp.((cAfY7.9-?%+M
><6j?K`)QN(B-r$mi<jJfHIh.O0tHr3EJi._WY"`.-57>ZK=GpWi`1op2pW64sic#^]A2BWZA
'GbpmLYZ9CC:hjD&Z"tIT9Bc\q+qX7kg>FdRQHqF(faXr11N+SBBg00&MpF]Aa$T.b$#F/_*Z
5$0p#(tRTR4M?'9emf4%:l^MO20m<j]Ap2s5(hY]ASW9i;<TfGP_s2"/2IqccB>SAL`Y+9UB']A
NXqUlHXC!la:r#[\c#c!GI^[/+Uj't77OC4RbP=ofCYfkB[)B"EQ"V&/6ta,(j>O4DE)mCi9
#Z+)1nSQY?:h7RjTA5^1=3Nf``3W?_&)G(+/,%tRtYn3n$?IPRT"=q9d(o+QEa*TOIX=S5e%
XYDHd')SS6J?-1eL3GAShs0]A5rCEl1Vki\2`En0K6Z&#Hn##7l70b#YOr7k[ESI41AjW`qDg
?q]AIYsmo!=[gpBmbNnmD)_X.,3(&\f*Im;^bEBA0DSi,AE))UYVc@Y,dj`9nk;,i(0$`;kpE
i.s-G+:mipV8)g/*tLh-*,@--=XT!tKWbk=O,H:6DdU0.Dk:<2A;+A`+(*2dGO9rW0=PTJ1c
^WQa5&XCTl[F:a:X(g[VS"<mD7&>eOQfUO$(J@DT`jS4.l>Y6/&MT:H_A*%8T_LT;6pChjuK
*4oXTm9SFA.E+*ts=k9dVf!j=mpb/MH1SjHHA(1I$Qo]A:nhl"E:G,IbY4!<T\D6GWtE4>^0%
1ode+3G\0\/Qm14o,L2,uq>eE=/#TRZ%B2?DL"BVI]A/gaeB5.UTpK?qcF2Sg-/!9i2Uj;/RM
0s`p':]AcbQuPVBo:BZ<,'qL*\.CB4Tjo/KneGc0Vn3:"(#jj<m#i%n1q'I,);_q!rEN5AZm;
X\[_KG$D\^>?4qTXTdBMQb?F*:fk3/8#MgG*\jsJ,qio%FgiS9WIM[f0Uu9S%VKJ)PKS'q@p
IB$m$rph<eXiQ0C?"biJce40W_3[I0o03)0'MA^-F:H>T@\3S+*Oa;$/oN$M6:=0lL>Q3bs=
-`cI4$-\_!(>qrZU*kR@Dg8=aN::Y-JlX3^[)F#BTX!@<\bq28BQ(d@mn4N9T?I*J0qCp#X5
n<Y/NG@Gt(dC71R]AT3D"#g]A=Q>GA$$rDkR*;Aim:U09pm-6MO<6QECh^6hE``';DFMXoq"1D
QiWI9NfpZ\*TF_3WU-e+YZ)%O]A&h'^\&o7I7XG-n1gm?m^>6%>XESQ_`+X*EE$&1[#^!2h(P
6#CjS0+q=Kd1,QWh5R+e+fL%5'oViKf0ZCrPsR6FP`E82REnohgj@l*Ik5Pnb9e@U_oVK!'9
jhD$8Ic6\FuoTcb)[f0sofl#i`^WQ!9S.*Db-&mauq(gB\QrVCY+R"N.?KgEGKG'D0/bC3ts
B=o,3^rU0KBiHY&bfB%C7*BWO@h@:[WIPE>lpQFU'M7K]AWM!;dAXj(d.N`Z!NHu#n:h3cKUe
]Agr!/>l)&JML5_JLsm.@f$<MECJ?@!J]A'PB;Hk0h,X?5clEHDd;E+6N*@55n7ggiWn$13\jd
D;SX%UY[V'2l@2C`2N9q#4+>KA9%Z$H,1f%0"RU)g-S[GJW_^E'u]A8oL5+U\C_]A]A3*P'8TBb
,(/+kaAGu3/)ba:SRc1YNLj]AcV=k_W:!pa`mR:NB<a$'q52?*8H9c_EFX[/)IQJ4$/$7Rqc`
br@Qqkfe[``Br'S7CS+BL7rc,i)>)r"f\W7F0KLTH'>"6ij.9_u=89iOR7fUXDZN$plR(5*)
^:bT:LeXQ[PTM\G>g:95MDpV]A'B>p=?;o^AWbN<=_(:Z^:j37A2%)(5\aG!5;VAAq-9DN^gg
(*\!pV*QL1"H&2!k*R[0BDXL-uMY41m60Zi!8YGNK^.Ui[Q@eV)IOn!%/):]Aj+a7Y#*R6_3o
0ocn6tl8_)?0))_Di(ndMYf`g\PGaMUo"&/V&43;G5$E2\m`H]A\1e.8_2/kGDp_)H?FB'[mV
/8$!?H0U7hBF0#Fp6be'QmS!f8G1nel_,(`=e_;4i!o8W]AR$T/-WQ`np*f"4!Bshb-KlV^X_
(Q,^R]A9Z$]A"$VcuHFiT?jJ\.Fg$cUuo7E#6%ahiODPL!FMDB4=?O[ULuG@f]AE;hqM.#2Lh1k
XAMNrY:s)$tR)"U3#iR",[-%a."&%2A3o!13aRKHYp?<JO&p=NnNonZ9D\qH+9L[O_!`MuaW
<bl[&>9D7C.rd@@M!$l;*NfK['>La^>iC80&m%=7J3>\6rIIb,>:eXYJ19fE[]AA_741p(!6O
E:fu,]Aa7'D'F"aW,!GEl_oD^1E,]A0r1(+6Wdp["C?+As-$ao'*oOJsi]A26gLeZfLt4Sj^CR!
P"53ebSAWg(8!c;S^E=e34e#N8Q-fqQ>ioW*,SMbm1;QBR4sYjkV4*bZcS790O^HXZ-k;^rp
?l%C+AbZD9(^f`+T;g2E[CDPkf?[jS'oSON,.b:M%B0i9HSVNijQ\R:+Y`.gB11;"VSBM+&i
b%5=nd%R+G]A(!-[qZ6`!aR'>TQ9dYHm-LM@_L2eQ9LXO1EU[+*W@d>mo\mC$.(:$G`MD=\dR
<7%2)Vd5\8ES2++/01Yg;PCGQ_R(uSoo@p)fDftlsDhEU>rs1G<B$5dqbL@p@=htZCdhf+&k
pE+`[Z"Z1hZ;DUB>3%Oh>5(82#b.!r*o@UcGTG8<ZYAbAW,29\>RX7/dW[k4j,)t7(,.s!\N
-CKdZUW696Ed[:URK[j]A7J#/+UrRsRoQ!-"-VMO7%.$XEm#FOrYNG-##bD#l!=tS/PteEk7u
WW<Q)U^nh]AZC);W4B]A,\?DbpNkL8'<*X(qbn[I'o,ACR%GBPs)RYKLG4iOV1rU[S@Bf9M"Hm
NK8ES1!/oLIJThtLA#q^D7`'ao,Z-4>aiicOkUm1o35\'K1U[Ou6X(G,HE-I,lMn)kJVp@$7
b%B3L>0[YjPd%7GMZ=c"9QPe_s%N31%/Bg8KJ9?D@aZX&9i2Fci2$'BH9=Q*S)3oY,Tj,dPi
Rmi7fgr>?IZV$(CDK_oXJh,T0Ete%n[EfKWp&)\WleZR9%CWk,F&pG;"^;FWq,m0q=0s4h#a
7gJF3$/3T]An+[N8;[J>^;frOi(fQEjga:CI)"k,fc)7tZ>'DS^9&p-/Y'lO"/cUg4JqEEAgg
b?\N$&-I;A,_'Z64=#iA$.li?H)a%b.64c122c-;kmA#JhJNp>YcLU@X@Q+AI9V<Jr!Y6J+B
INuEr`<_3CV:Y6\DAUOBaHjj_/M:@q"M:B@g@7Tt?i5c5P/6(XE^qeY+@Y")I4$45Mpn-b'%
G1ab&GS`U?1f/??@bPJ]ALGYrncfZ88)frJ:`qLj0P:hnB&(DT@))YVl!*d!pI%*&EDnn"%*4
UTA0br%rl)plh_n4WePj9G3nH-:S:14"0IqFPYYr#=Oel<8P['(Wp*Kh7VH]AJCIm1^h?=lCd
qj$DY98j+aE28G9#o(!LD_m-;O<lVPqG/dtn'n!KlVb-53`;75PfJ1S=NL-SI7:p.H!UZb)4
M</a`Y+UOcaY)o@#RRpc*"f:3QSBSF9O%kNGuq.LX5;J6\*%8&$jr)AaDcGr,d6)\$r2Dt2?
ABi3F^[g0Z8/F+'=1sr)0JA+K]A:4Irf$;^,+$epP0Q1G1:![.fm4GD;Qpjr+M=.D_;bWUKmS
K<Hqmk6?3St^m,n6h;QlDZLG&u`^kHGjY/UcgR%2D0"a9oKl`]AbHWi;BD.5(A\u'>lHIG89)
r&,MOM9Kj<dR6&7&0HCQ):ReSe5&f:MgF/Al/+4jKf:VO,YjGYF^U"GBUBp&5Ilk]AKkJLmUg
LR'b*q?+ru&_\uPWE.:id.N5&o^t9R3+4BM&)IHPOG=TlDrF3\c^G9p%ECUM`Y.'8#h\a@Li
T?kLI[FR5^KX'IIQ!smL[>'?$q(3$UB,>a@MYs9gU"Xbu:=)n9F1E,e3'SPVZb`>"#B^nNdX
i74JkZU)9H("^A(^CeN,I"BrQ#(WJ/*6eL%rZ=RPKUE^h]Al<iEtip'aqG+a/$O33iYhcZX]AH
hgaGEi4k#X^D'**gVX+$">0jpg0&i>;FRijBjJ,(.J2K-89,nEl"$5J(bIpn3(.E;u6[#C%-
,VKTNp:<Sf[1[@siL&b46l=gg?$^:>o.*/E\cNYM,/(1'_!W_qkEW_r#qF&M6ihGS21Kt'm8
n!1;s-\.-jJrVbE<b@M51UY>"nC;2IYeNO5f`Cldfd/@b]AY3M"?13AFTUFaUTWhCd;&ReF&=
K1Od_WuI$pGM$ofj;XIm%S!?UD?VJNp)=\rm7.$E)]A(H,Do##*Jg]A*OcBkN,-3<aq3gY:^bp
XLC,g7E7[JS7!;'EOj=CE'Gfae*(6k9?QQL/,Mmr1/(K-QIW;P4n1i1glnB[>J<[7qJR=UY9
loBDk93QQ4^pspcSD61DJ6i,rCN)TL/_dcjo[32p8Ur<*s6*ts!s?)(K=$L2jsLBGD!s:24N
"/i\sC5/+6b2\jKAaK6ee.=oFhtq821`K%lc:["V4cmcr'8?k;/Ta<Z(dPMM8taSrXEPH=uT
:O0[@UYqAb=h]Au^TOo(gPbLC>W/]AN4lV/#aJY2;6.^dWsQ<XZ:RLBH/7gAI+,bgf!Hbk>mV?
+-ORd,IJPjAEH#EoKQ?CD*Z?:NETSf;4AZie;Lmd<1drX/qT`=S2.,ULuu0)6ZMCI$gLH3_"
mIMOPbR;NQ8I<QK3_#SJJ>0>tWO_1F;nM.O@,d/lR:t>LcaY=Zhl<&:W8am.T>>DK$U"DC,T
0%Xs$bOE#6DQqfZD5]AeEi`#YEi_cTE3';q3u5E@0C.'l[u[LWK8la#IF;GXP`(Y3cVM4/LU=
k16EN4$a/V-R`d4<QC_`IlAKsWjW8'9,OdurUOG2ks2am\oOfltfpUBPc-jar@e"&ZeP/mA(
m,5`)VN.B#;gc1)-4"u]A1m.r:$HGErahi;hTq??pO\%&mbG7/6b%*NJ99dD&!&R6j;cee"dh
bW8c`nCJpX<l<Dp^%q:Nq]A?:KOU@DjBXip")j<D7(mqD3^$=DmcX*:ET8*L)SU>WqTAr]At-6
l;;n0&m:1q!e<cU@X[1+"#e-iE6gg&kdqh:cq-hj*a3D3dL0tM\>Yio(\UqWOR(`4MZpo9J[
#YMGK>j.I8dn^YC'6F>d+iZLB6uD`*+u,7X'PVHAnCR+>=\U&#nuB1$"ndoK_9((5>#^nfM@
XbBb,@u4-8]Ain)7AHmL<.Zi;r.iEqs/"Sj1-`PWQanPmLKidnkD^r7%qn.@Wia?`e8M!nR/q
K_+fE_K48NP8BO^m,g$)Gu'#1qTr_Lo19b5b%!IfLWFTTGquFrBRVE#"k)\<;6ttG*&0h2CH
,sA^e5Vdal/cMp&tHc8i6g]AW`97h30a`78jil<92l,8]ACAiK9J3\c9FeGN9b)PAH`FtTmb%'
@7-D+AU$n329@4aJ%/WNocqu;1B*:fb8QIN4>CB*%rMX+ajZuq"UCCIRrM)m[Fd*;(:G0Qb!
h]A1K0D^isb"6oAr__$\]Ala,+5/,t3a>3F=^5u`5Ka2jO$c^=qO8NX:jZB@<WD>4>jTapmTT>
SXn"9+)1`=t:=qU0[ak:+YXH<6^^^\#%ii7.2h_Ra#[-J744$jJ'eL-e*APG$E9H(,0PSO!u
H^2b[_#@<sn6ujq2ViG\]A^Ghn4*DtYhK8Ld_B]AVX_4eQT_E(@MnfbO@`iX6'NN^H7p\RQg`L
nd_L6KA:WR]Ak!^+uqB(&p"<#E,AjbC9$n?CN0'&tpZZ?5]A?WFFu*EjiT5m2LBj?]AHn=b,fV'
f@A5!,@A7f#Y^JOLaqD>"?p<=jG7IWUT935,;Abo?q8qN*\e?@P>Nk6&Gj-p=@SmE:PFY.Jh
49TZBYt^'0>od1n7sH2P25.']AXEa4\%*LEU\9%2^'Lj^@))PXpA6?^7>$cP6EB<4qX.sf'..
a"D,4F(2b;rr7-DV+hd?XWdiuuX+pG*RX79o'9)mQg@'lBa5$m-HNnsYl)ZNlWZJf4+>gHZ7
7ndjOpSSWP2d+G[LAi7Y#Fh#c&%Mi;jTN;N$JIk'D;=l_a8l.gZYt$iVpfV!T#nt#]A]AChsE@
)7bZu+JhQ<l)0%*cdSgbd5tFm'NdS.c_MN`0>]AjK*HTs4/*uijisJ)'_`S)(d4AkfkJ<kUe/
j6Dkq1V`^u<-f&MgF[3et7lF0ih-jNSfWf7M,3`"2^@bC0Yep1uh3ItYQs`!`*ah0M\KT1R;
^BAe&eZ]A+oG:mcK56S3>pM?fM'9:MO=LlJB=k\bpIj$b5(@fOc3t8rcdj$T>-WciVBM#c8uC
kKH?XbjVO#EO-n>W3HZVAuX$5?em>Dr*2$cu!f6fu,KF"PuFsYI`e2+tZ(>rZ?$eOF6o[M@O
I0U(J:BG<*-Q?G&"B'l!7%`Ig,M>5Zc$D_J@BYVDB<[G9bE)B*\B]A^0.ZFlb!NA<!+Z2rl>V
u(V\J8@eB\l>.,,V:!]ATHQ(Q\RQnVjd="CR.07IhLfFo\h#ba=XKuC1Pg;CYiZ?7iE%'C!9q
Mr9Tofir31rrT<DL@hfE_+%5p#hs&?3S`sMd;aZ/Wqc2&_N$+DRY`PGDr_\?aB*pTndFd:lQ
,!Li8I>rkJGOX<(l\YbYh]A!^4FRO*WYeEDk9`!:2K9XVoEa;Y_@'UJ.!Qh-5afau3O'U%D:*
:^W$FDim^]A7;ilp<bk?Q>A>NBU=2tq=.)gWB-5GKioH"j>tjV2]A\?WVM-#DOmgp-Oik?faUp
jjuF^_';LF@:V(*fef^[q"ep8Pd0,^l8+NtYBio"*$I?H/J[!?/JX^ibnZ[MXVBJlTh"<=:*
'(Nf*3]A"S2M9'",#VJ_0j%[K;ra1-?YW[o,'>@l:A`BA<h\1\K7*?gb)2Baf/7)TI6a1&.l;
5;GrM-B@D7uf_t62r;2m!^/89$Fa8s0>tK`-cg,DDd=QU7%)'$hJT<99M*`H#R6kDS\O('`%
&AuANc,_u=r3-"Ddj)JW1(%uC(&B@%$+dk`$G?+<VW1Id3H-LWWXGi6+rtDUDili[(3N"/^?
H0"uF<B3BlD;?#%XlB\f\?G?Y.HZr#=6WaHhkUuA!ROhS\U<>PWer$4OH!lm(!MR0[Z1R73N
F_^-#\u1`%FbdiA:kt5,j&`I#("9St9!I?i(O5fY2%eiB\f*C@A3XN\r\BTl&A6aF7ddD-Y:
[]AQ?hl06=f1IoRAPeY=m>uo'E*P\dXY(!\gdlfc>:R'E$VZ*T+t^DoD7"EdHL8UD-=JpkJg&
IVac^<YB$DQI4F!4E=lr8=ko\>/aoN`>Kb:riCZ:pM:THj70:HBqimPU'#4)nnrRf0[^P=1g
)ER3ZrN79k\?jl\KF=beMdUeq2EsUK>q\)23!qU)7$^qBQcRD!+U5,`4H$-S`9[=5>:L]A4^M
=o(`EjU&D4kXYr_7JG7ioQm*#Pj;AE>u2HOScoh(r:M]AnrB[?Yhj[!C3G4ae`idTs7EO\(Tg
g?dX#eEqm+pl#[.i-nc1Nru<L"SX@f/\Z.2Fg?Xm7+%/):k4RLa0`fIO%)c8N3*tAmo4'1$I
K_NWqE4r^Q65LP.UA.2'At$\O,b?Y*,Cgj<5U`n6Hj_LbCSmFF,ot`jB6;dW@[>@4s3fn[3P
h7;Zl2S!7J+RqKWm6m(4ZYd%Kb>l'4.Hm`jODl;1EVQSBLs7,\YF!T+6MUI#0o4m72pU4,Xo
*N\N-TA0;/Mp%7CHSk%4>o%)keshjqP#`CMP<_e14Iu;%eT/$$EB`UQdM:Z#iY.(QP8n8MIS
Zt.t@&aR[":1N(BA6MaPL)c%+-%62=,I2?]A%Qg3c1LP)A6^->&iSK=*j!e3Yg]AE=u9>kWr9H
=n6A$[1TCR]ATkK5P@^\fTB#VMO;EM.^L11O*6^E=L<kB#!Q9/kc.ZDE"VMV?>Pu+9\[R%X/3
oh)rC?012N*YSoQ$]AWg.Vc&gIuZ<gU,Kl$Jj7N:Z1#W(V2i*\]A^pn5im\ZdM%tsM&o[lNl*[
ejn,h%RXhtI)a+%la'Pg)@$S:ePk3]AW`5;&Ffh@]AJ]AdN<5_MXg2=1f+rll&-,gVMl"5C>WHp
3?:kK[NO%n(c]AQ@&qpn?^1?tGgo(43)btQFQsR2q%st0QW>T'[spij/oXZkO5M0o9$u%5bMU
XdPP``*7`3#T*4g<U2=g?TP',YS?=ph<9nb&mKG'V#<jh!5lP"Q60mQ\OmJ'NXJcDYWQ=09K
1ka?bgJA7s\eJU_L\HT!E\LdU`QIsr5afkhm6q'3/AdA$*YI`b8FW#&eHF9F]AP)MrKPc<(-U
JhDPVOPK*bcmcLOFcg>Ma/k`KG_"fa\^HZW%5<#^L8kpm/2`;m7JV"o=bppVpK-lm-Bgq%V+
KnuN&84fW#lllNjaCk94BF]AQR,']AoXLI%3'&_]AQftDcP@Z;SJJMl.NfkoJ;@#VU*Rfph#!sJ
E`R@<%[O3rEC\L;uMbl+#*4#%aV>_Mip$DnApj^P1se8Idr5IATX:-0uVFlO`@AM9[()W,uQ
YO:eWJ'[;.qRj.cu*BRDM.I'WM/;DN("eboK,+(MH)j0-n1O%?NtgsL%75-r_tXAnhS%8K_G
>VZYJ$LP(Z%DE8;;jT_'\CO.gr9;im+2R?jnG\s4<ph>T1`9-ET+G.K#UT3;i#ruSl&eF1$f
dAdm3Nsj!P!ruK']A0DfjZB/,(UDIcqV)#"<qk!c!0eI)?5AK_`&DF8FXQD<QoGQ?f5`)IEpi
.Frp81Y049e]A8<%C\;?cm\;,2\Pe"^&kG!(Z8l>&d<g`R0W?*A<&-al8d^1tF^g-B2=LXY-q
PSgs@'k4%BISF:$b"E;fk?jJ.rN-e)M*7.K'eN&.pDB4#s:nt#&(I#O\"@Cf-k9DmS%Aj7LL
ojhq"R[HP',b":u?1W@)\L3`$.Y9p.YODo*QS.(Y/Wr5?riV8/G.f?g@dPID4X`uSq&NZ$I@
*s=3>M'FWjKHfWukF\DM$E55d_>]A(CKmi5?CIgh=)(Fb+)r*Jj"*AfUD(sM"YY^1U*r%E&A8
73!s2nhr"6sk&7-'.&MY)@i0Ig1,is`oQ<K$h]A:2kTqde5j=)63ff"^fcOlfDu3FUebG@V7s
<(2oE]A]A<6HgNP+lYD0pQ[[m$/MVM:".'G]AD&,n\u@ap%-1qeQB*1@YP51A-?)#AU$qMECeYA
<L/P>E,V#n+\ErjKA$"`1"D9>X+LUg&F$gZ;1bR.5'%hkrE)L7Bf?Se=25PF9n-Ta7.eScrU
8)s%qGS?AGrL-NQnAg3H,"I-C#!</U/8""aBc_;_:._6,l8EL<tj=-6>\SqhZ',KPI:n95I0
%$f+`m;/^e#3'iTPit\[n&TpcDK5JGV(LLpJ<Hh-e`u9\'WVj\gXhO5AJU.Ye^$+hj@iK_R)
V`SKiT&3eIC0(If"-_5PB+EL_25_&4%oYrM+5d?u0,m(hA;o$I-pu%KDHF68i?lM11tj,p'"
Yee9fcF^ZPE++I/fm7!32qa1n4q]APmrGd0ThmoG,Dh]AlM+no3adJ%?Lk07Wc+5d*c3rnIn;h
9PU1K%GFs)!B&(YMupmYF5[p)KU7mZ%S63XnIK5C=%H3lPn,9fQBbaS,Ni7L_di96:DuMD_:
huRDhqBK.3$R$'1_/F.L8o\h1$VZ%^^'l#OC8!Bs0<Cal:J>nN586cp88VCSN#N@V(X+sZuS
PKE*RjbQmDkZ$JEbf+/0oPL0sbpgC+BT!+oSH$oJ`2VMf2iVk6!pqO/s1^;4Dr*_G4I8$Wl7
>;%JSQ1%,-[d!NORlS)=qh_.[&GrK):fl9[WbH&Q^B=7@c?^l1YU-HY//YZlP*9Na%[f$#)A
PHn8VTD*c_drZ:i:\*XKe#;E/A1\38<Xm1#rb[+r=nB_iF9bKUG#3)a@/W^3/T4#4QTD]A+#!
\(E:5is2rr36!DGtK]A>Z3AqG?d$4[.c!G(L?8L)d632ZUGI1Vb%_7P/e9Q`Xd[\-9JOE5#1r
$j-+;$OlI9]AsSK>-=Q8!^i1[YE&)PPuZs.h)?ru.G\@[&quJ-u;9G'nB/Z2tn:KnX*kW9*eO
4/,SXWtJ5-M@'VVrM4cJ4)?bK:g_`PBGPTm:r*%8G=,!?DpoI&=_[lb-&!VmaE)1KRp'jYq4
2U4qMqMV_+(3/f:@`VN5gR+2bnm6R5^7B)CdUYWIeTB1?KI*[%_q9M&Z]AHJ5[:;P(KjU[7*r
C*B//lLLnLmK\B8XY5Wi'H?^O.G]AU'3)p8+gah=\;k482k7G]AVVFa"38WX$M"R*R%B^Qn(K2
BhZbD^lRVX-@(glZ(:AW:@'Pfk$-nFJ`&X3q*nlbXP^X[oAqKFFMEg,%%`(QQOP4hnj#XS^D
,_H?W#/R6W1n+,ic8*#H=^&C:*-85/TM4sk<J.Zb1/P=Vu#;\\r%mGC>E,)H0Job-LUWO.K`
@>nqpam420Y]AOWQ+#<PIJW'PQD58rr$qDD0A(7#X:)lRJf,/CNl5K2OjXaZ09#G#iY+0B3"\
2D=aP1K,Qs-g%2Uo:0^S.dEeH&/Nhk>@QV:Pc+*;&:h!t/:Ik+<Nr!X%Tk;E7<cUt(*qHpC`
R%[HR=9[QM.V$P5&)Je1N)WJ<1S"ZDPPSc.0>dlUQo9f!.E@<?Rfi4MsjHnY$P5P)m<BL`)C
(7.">J(!oCS8oK]Annu=iqR>q`UcY`Vs&_m0SGiX-cBG2(_+!SWn1(;Hh'+jaRUm1i%[0'qGA
oN%LZ(!id`;`[dd!80%Hd@XcG<)ci.(>@-B!ZVSE]A*GNk_pN[s2*NhNm#,0h0;W5TNVR,X&T
&nUBOr^%6mFYF:WTuA@#BZZjt28=CMTpBg=%%%1:aD3d!f8'?r7N`$Ar:/u5AU8u4"=VAFee
j2r&.*M3(jqjW)YS5Inm'%E424C1I.%_YRj<#DW)d<tJAK,t;Bg5S+CKt;VesDnZpFmO#?.k
I'`"`O7FMm\[&n0%qN\i4_"60/=M]A.e[?f?r=R#8l[X2i2:\Xc2*5!Q4c"([+YQ,$O2N3?ck
_,%Q`$(X@I(]Af20&9^E`M'hqc\Jr4ZAo*OUm/2DpSuVciXnr2b57gh[?:=81g)IUn"<F&KO9
AAdUnk$KpOZGUaM`kB;=DO'E/ms/cU/\c%cr,.i#/@d0d/e4=RArP\*Kk2F6A:"KTr.rD1uh
$,.ueSc2E!Q1XOco+W[<=(p]Af&1+OcGa#0VFrId!,s#n0G71reJn4=EW_Zb!A_OI6m+jW63G
0o5=5TTjp/!GU2ERqd1%N,V'V'E(9`G`#-beSj-XpLf_TrQ:IJWB%Ptau2bEOeY(S_Y>nD%h
bX:GO)#tY@s.7%9N8mo*#Y9>kn[##G31XH$,en\^/TJLbV^>_9$I%WrmFjAE5C0r)nm=1H6!
bqoM(WEUVk<a.';_KV0AQUHW*P0g`(:`)pTo>`]Aa;Rr9U[7i6(DJnnn$5B%C5>1s&q%J+&+J
:U?[b/r:TW",fpnnVaSi-!p6PEX0<0o!YZ\n_K@R>4\L<_0E^LI1!&<GqnoD3lfcbjib+?3(
-Hm^Q&D,iPXXMX&`&*>]AYk\5aIVXpfG;D6$6M138dV2*>L6fuULLP$#_[L$NOmg%2cC>Vt[u
/4scYH?d[Lj]A'Eg4c=]A"))$Q-GE93YrXk=S!7PFpR1AdjplUoro3MTjGWWLuFKE;s/^;(]AWS
<gC9B[s0I"Tj-IgaO+JL]AJF\n/d$#G*>:qL:&hNOm?`Y\g!T@UW>7bXhL7]AA9\d(j1`ut&nY
@i2?@uNU!1^"hDTrA,,='TTX-9\+Bd"b5;G+:\3:e?!L8j9FrN&L+>[1>atYO99ULT7383Eq
P*E[E:acZJEgZp+1!>aDi1b`iiVeq!$0eH&0mktB+aiGIl"WLiOlpV2-^BtMeLfa<=^Zo58d
K9c%ukC&2Wf!3X1Yi=+n!s+3O!`:mXI=X%XVfsMfNiL9rO!I?URpUdEZh.jZ50?f6!sP#G*C
AIJ$&`P2/Zf1[aOepbkcE$4\CZNV&r;KR=Ck1l[rgU"N[<XL.9T:pm;;rt7g4AUHXT5qepRs
7oO"+;Ft;MrQodRPo[,k)CN<W3AGNZT)U35SA!"$a*)2U<<DM@qDaP*,O'f)gH"j0h:RWFDN
YRa!ms2$Q%X$Go/+eVjDc:K*6QsPR$b>*L$UQ$1>jhbOL]AT7YX2BTRF.sF1k5nQbcHiaqhXa
h/5Kf>UZ`'kfZO;G%fo0Q;(?'U!UBgs?Q0Y`Zr7H2&/d_%N>+mVI\!EP=7X?-Z\-lX8(ET/.
H-N.;e9+;mdL"CXe4CX3Gsp6lj(>^#3NLXQs"SuW)68I<jZdI;YV[&("K3\aVt]ABB3U?\d5=
f*Q^cg^5m:A$VGa4G),cZn\n)OB/c?<3;+l]A4-/kYAs!(:5MF61gSZPT[e9I5npLF`#2!:4]A
Ph7.kH1oB9@[4:InodU(L05J;*7->8=R4eX$i=uWbAU]Ar0Ip3`S'A[1VY?L4c6`cPh%#(R3@
9D=,Td8Q;.qq>!$8rPpk.Zk7&Xn*idh3P:]AAfTn9-6c756@-B(]A<93\c(oRqr[Mg_'h-_W&P
VWk>:q\4,#D9)72F]A[.<9-:Y(X-S/'QR0\onN0Hd5oX9_OWYX[PIG:DH<!!ECTQ&M*M.D@f"
iRW/eg)^5?c:/?sZL'c8#-EH\TWhZU8+Md14/fe#Y?M"a]AfJCU1n$-gl,l!D-Y+#q$p=6WLW
q`aL$cWqMIpF&Z0GUE-Km&MH5B6ekHKBT2Q^E[Ue11@?W3O:l3i@fir_A!NtdM]AD'rKh1/ot
+[`L*4$WWu7@n+Eh!;!/**1oW1es!ld-O!JBT\bl4K8=pS@J0G%pu^GSo796_"WrdJ(*#(QC
L1&X+oLZsVW+5a5'<@@d[QWj-`O<P=*[Ci3>\$J[Iq=Md>TOM(H%ZJ?;.P5C@6'UHliD,,33
ieC\SZp:^)Ha>Z?lU?;t#uK96&9phs%l,Cq%Z97BIE3r:VZWp[J_L+7g#rWKh1"A9o!I>U:*
=Z64a%&`p"<5HR@3>u@%PWL9-DKG?.le8fAgX,.^H27-^*l`Eona-2KiGFiklglsjon!Q\ON
&nh,^*4t_^B+YqP"pSq<H;_\^ESV!;K`U0"urS1+,!G$VpmSRS5"Ke0o\9W[R*,G1P<H^\`h
[/+sZd7M@S5+#L+Zq4E&PeG8GVi6LiTel9P_e(TYr^D.FTcSEXP3lJL!UQFF]A@ZJGG$3UVMh
]A.#ans<^OgXU09"9TuoEW7>A!0VFiqA#,CI]A5q=$K?u5;1oY7p-g3S(B1Rk!iVTn_RPX1hg-
;gGUJ(5EC0WkE'2+h5AG3rrAtDTOD*]AmkN/2XOHVs&S$,lJE.5Wq(#_5=/jF?VVee\MP+B]AV
g'9OpX/WdLLMLi)g_T,UH[c>Ueq45@q1`I69^eaX6#utIN$ba[f32V>U/">dkro/C>u(L%KU
?UY\]AcXq?[T0cAXu012h#);WbYFRG1bNO"gCGt#gsMd,3.dZpq,2lfTTV0aka!?,j<X)8lWM
b8fb%Z2ZZVu?IoHO$1FBd.#id-bhKbiRPo>2#n,Hs)&9Z)Uok)s"5i&WHIfm,OcG"!=_4EF$
B83X'*k[6pLGk7Rd:'3$%OG5Z%H]AkN`K(u)\mqSmqJtBUo4_G\23`2GareTX)#QLG&:#;C[]A
3o8e1nTZ&9I?0a9hcH2`rd.'p(&EZEc-&I!VZhgtqXhFmbYa8PP-L'*AIg*h!?KcbB`EV^(,
V[2]A`Wl8jCWo&m$mVB2!&D$Ca3eIu6iV026bM^Y#!ab<%G80YSF2%R$f%L`7Vq*gP![@80pg
?&!;(-DJQ0(#G7usZH$9E`*YbTWChQShgcWF_#iV;uMB2?$F(tA7GS='C)hY,[:$8TSK!<%@
3mS)/T^^&Ya?N6XVB)VIcHcK+%"b(*53O@6n=eE^?WV`M"G-4i<MB86UN-N%=)@&4]AikM;Kc
!&Oq@?mFiS1cI^W3U[nc2e$*85VGgCkj9dh/DfV!^g>k$dbeJm\0QV$mobmWCm3oTsM*ERFV
4Rgp+DrS%f/=m*7`4n#'Hu:CJ'fc$dM*)E-G>''2XJU\4K9p]A!MhMBn?mTqHheE8,SRAM*,1
$]ADS`(UX`k^UZ@5nY<t;NR``q[V=)^S2ASZdFT6)GaKA![SkJim2C%GRMsNC5_2Y6?paenMk
d_-GHWf05,1:3Y6I!NYtYgK5Fck&WNc**e/C"4Oa@Oig/>(+q5*H1fCMW15*sULd.@BbGL*1
7+aF+o/`%h8jGKF:)r@tGf:s=A)d`/=g5+R;3nX.P"(\\!%HAo:'oQ+uF"n@]AA]A1e%agma:*
@ErmPS6DR^HuauD03fVK\h2/$1L0;X9;#n!]ADK><#,N\l\Yk'cBZ&<LeO815\u-(_QItK?Z+
\f_TSdiVK@!;jZ+e1kc/m6:FKc%a!nAXo>&;C5dXg+M)5O_a\M@oifOhY/rG#"08X[Ig?u,4
WL]AW1qrHkOW/jH:s5qmd43a[LF)9m(Z`>5Y6rK"jl.PAD0'KkLS=Er>VG(o[Gg0kpl7PH.ot
tq474N2,)BB/,NqW)t&GO[G^QGVrm9;t:lMo[P6J,DP@VO_&nN``A7"+54B$^ds+#7HG,(DM
gA2(^N_TGBpXo7b21q=ae4KciKA17f^!Q<X,q9?W@n/JT!!^m,Zj[qLAgqPW51B;D[0gnnjL
gmcPnB#@6JOJbJaMQD\3Y9Ra2l:%nVMIAqRbciub9-9-[:dudL^=0U-uI4)^iV*e6D#8(]Ar@
rqS$cRNK3J<(8"S(MlqX?L%B1!b_:lDD;n*q&ABT\Kf;O;0DA'-P,T;>CB8ZbP_P&^>bE$o)
+W/7\oP30Qh"<nLE>*Tdh:L9FH$q28T07*;B#K[O5)AI_S%U,.V^?^!MCUg_HR#k.,$Ws1B4
\\M.LG53Go9haOrZRZ!Ik-AN4?ot9Rp=(I)9@Z:.I2b4<T#=/=q6WDArF%0m$B8T*gA\OIML
M!%oQ6!b1i!PUP9JJ(*8\p"*TX0U!p0%Us?n)9Kq]A!B$jI:!hL[a\iUlgeer\,.$mlfqVrI)
KPe`WdL`9b(W!:ndYo/dpF&8@*`l*gK!-u4QH:U(IW=K?E5;+J3J/U:XsT[]AX4m4EcT8H]A8u
4Y_k#pW_.MLJ"i!h.Fsi:9BFB.TcLta1YMo\W$/<4$]ACeC_FR$1)^pF3DYSHn,b_0,BZ>\9/
.enu4)O,>gCFGORcXP^#Gl6WY&P@bQfnHiuWb;6B@o@>sRQ?ei-Ai9D;XM$So=oT,,TIc.lC
2EM\&/.e#)TKb:I5#9!L^C@1kfSji2B(oNE1cjqX,>6#3OcH$k9!SfE=>/n+qG<b3DEhcmIT
5Sk:>\R5:--D4O1[m4,mj9ck<-BsKG["ggp3CnQbtK1SDkQGo0>ju2Dn0pO0-F=mE!l%7r'P
5&,(2A0@@>&gKJr:F6?VW18lfB_sX8NL^G&5=2OTD*lqC&Q)7UHplhdoL&e0'LY@!B@K/[7e
;M1pVoSZYTFVk-Crc%MGd!!$S:&r8PN!"I:e@FN.*EA:mdc5jA9\^<r9q<Z!dWGT[F(iE9R_
@`jIr#s[FtCQIh40gr,CYrqs!kj=WgrTPkEVI_taT!pZFVP1]Au1#<_!06GN3HFZtSTf`B(Ic
\'F*ni,'JCI>BU8e`t7,FMK2Ti^/oNQ"$bS_Gj@m_H365tBGC!'hU%>YPIXAsshp5AkO<<>e
qp]A\T<m^>&TB^@0.,Yap$5TWpF^$e35nO%MT1[S[Xg^L#]AKZ*8&687Cr[!IS]AI3nN1ia-WV1
&C`!>-l`t6C_6fX3iVf]A?jF$GOdGI(O?u23"Ish]A^_7[]A]AUA79(_nohV:Y+(J!b;hDCCQ\D`
E-]AqNc#1HC_uc<>[gj*,e%-u7r:+agS8EL+JQ!>7G\n+K`l;"!IoOQ4@jIXB'FM!XNdrqjGI
%K4nN3sEln?-5tb_n7YIo!79UB<!uR^jW9%)_qOg`']AWed)4Drf@[K1<p+3OQ"%+J+8u1'`<
?.[QB9#4ZTumc4$lIc<BF8+6i@fL\noc),6C1Xe<ut\<@!:#J'\JI@EX^lhb#8@lg@a#1Vq@
9gHOb\X=+C!Y$?iZE5*L/fnD0DQ!gLl(Nk$`"fBd=,/8tS9S6;?CBHY:A*)RTY]AF%%3dcoB;
I6LF$kFLeM#d95!bU#$c`r#ZU+_?J2#1^]A0+ZR9cb=&a<D7+ccir,dUa?^%NdY?<iVbn-9+P
TuG+-tARGp61,NAa0b+jLcrtRg,kt4r(5'\nZ)\b[hoR.cgf,r<,cXs_H_tF8nZS"8^U,.a'
A5]A\T>0&`cP9,OD.^$6Dd-TKeDQ>9YHgNJC2Q'EeW<R)Or]A*';#OO$(qd1Eh:4#b+B6YND@K
p1[]A4h2(MFFH7&**S6D52I/-DRueI:I_D,-6!RjS\!#qc*Qn"iOFq-CGT>AEbo(PGb^L9(ZW
l^#)67#k(<in?;F(k8!q'_^XOd36hX`D0$N-kMLeHGa,ums/4ZR+p0%ha*9l=-C'O)mPB\H:
lLk0Er`PcB8NGM4NBm]A8,JufNacoXPGgq9;tXR"kV!2uC+b?aVgs!^-@f/IEQJ3EcIWHa\&k
!`V"jh`+8XdP<Y''2YBkc?G1RN_rlpO*PlggpZEiLPA?5VGG;'lpjO"]AMkNk``q'ZL165t_I
OhqOrJH@pbiF@u>qWE?/ULOd).?(C!OVGDpZm-j;IoJMFLNX^:K^#doceZYb')`dLAQD[$-@
ejucaH9ss#YZDFWV"d+"np(:&b1XG-o!EoDl:?/Ii=&A1p$V+Vde`/:_TJRi(G-g`o*M)IEK
:#qJB/l9fU;mUT8NZ+Qcl*jb6qShf?^(3B.Z56LbE%?;j^NB>@.4QK&oeF6?f.b0B5TC\[17
?Wb)i$f2h3-C"Mk>i$JMkXUW<7"6r-+"6Gk1phW[EO"C.U]A02S]AOMJG2%LU%h3n@_[s7$_^L
@&BL]A&1<U4RJ:Aa"UMb)X<9n[`3K>KP3NO'+a/"W,Z(V48H;N6YmJ#;>-B'XZ22/Ou!:FG:V
aS5^s+GD3@522=@4r9:l&?gS+h5^cF^o6-S5^prC]AT.8%dD^_U.]Aoo.hg+uJdN,[]AT&)RSS$
(@5K"V%;_&]A!7Hob5j2(#rP54:@lnF9,h2cfSF[stsVY?3Jc0\]ANlg<0bdIBp)a1lP5o&.rq
"r0:*pc-\7!4u&<REnR_V_>''sY&j2=gh4;G*>t`+s/.GmMQcC&RY<i3Xc?Fu46\"2XKZ3h[
VacBd]AmXNl.EH3FE6s0q`F\'J*5SXB$H6V0qM6"WbOXp<;.abX`p@nlFX[3*`FNTo.o@h$[0
>^;&lB8e8m;n[@I[*#[@Lr#@=sMQ3k/&-/4p0ATpnaVn?kZrn:e4^9Trm;67foi'*!Gr%>PI
^V^fOLgKrQLtOse88dbU%O7K>?lIqbcb<+LI)5*hJNP_>K49Pq[O]A\mCOEC+=P\E!&"bPSGm
nNg,U<gEqHEX*lr(/o/N0:a<<_H_ZM0uHM3(`f]Ad;]At9Z*]Aqf^qsaKaU#TcpFb4PV<gKU*9l
@gOSg@L[8U)%l<Dpk$-GA_[$F<[MXJ&_;FY*W8kct:.3oY1L#Xer%R<r6_m1Ys';t?cZuR21
E=0Kg]Ag,5F`rR:A05gIYKj]A+AI@95+kT;65c:pdInkgR)MTnC7:Hn]ADYp@9rZ;urVHcU)B!8
t3qKUG2#pfb(mnMY6CRcJ[i\Mc$<2Y$Ki^-&W4me4#XPM2'&7f4G<]A.F]Af%:f^0L0:q^c/s_
^_&J[?M>!T:bgiR9q@UU'q[aQ5D->44e"nZp`.Q@DM7!ZZ\9N2:RXB)F'omU@c-0]AoV6d,>a
G%CNTPGR1jEBLW58Zi4g^X+ep?o44I7R6nJ!u"3]AldB8I[rGS/nju0TT>k0(&1?"d2>[1NBj
kg&WAjqB4H?p1E@sX0iVjpHuu2IP5(1_aj^8$2g!UpW;h&NGIFn'+/MIgt[_95,UOEf2`qG3
)'NB0-6DY3uF8r-.mLcSW9br"pH.-ik$ER[B9:[_^5>801;r=S\]AZJ!NO80c)Z-LN=,0YPgA
r3c[CY%3[\3h`J5I[cO^Mb6U52'3;acTG.\tDP?T'6T&.AZAs`8A*&1u><8;9TZl%NAUsJ74
c1=ACg;-BN?Gb4gD78V#[U'7lH#a<"\&rQ_;\bVpl"2A&SD2A0T0.u6q:AXO;$VG10?tc]AoE
NfTI&5=85`u5J=>HHkT0;JN<8mR8:dhi2_/CX))C,9/%>r=GOo&4!L+Cr=rUUaMiGOeP\a@"
^M*$LrLS*LK^ogs+^6]A76Hi;`oRF%$K\O;?dG\ESXL#t#$,j:=8[FL1_bZAAsHD[0!B_(4eh
s[Q+GPn\g_`AodIh,A:*HFH;l[Y/>]AS@-C$gGc@LY%"[Y`6c(_pi&:a[3IK7d=G9Nr%gR]ASh
#X$maE9FJjHBBFe'1XOhE"[0R:^NDUrc)c?jpi=pd:fq;2@Gc4C&XSk'#p_K)GW#^CXdG-gQ
.c<Q]A]A;d^$E'FOheVQb_-'\DWE1$a>cosjIr;7PAHie8is/JsYo35o.6+XBeN-j#Z$u#tbng
L"WXZ-,=QIk#!A5k.VIZ1;VpOipO-S0qQ58WRt&I"1?.]Am?KX6bJI7nCMF86O.RSDlPB.1;*
2I;GO(LdI<rKhJCo!VeH9T?mTPjCAKqo[QbD"Gc=Kp'Hf'i>jfoXF!E44fNVZ--O?)`0WoX=
k*$RnOED9*jdNXQdGX5`rra7Z`)U%Xio>VXA4cuLW?FSlR,Hmj.jmn;q4+6GipA+M_Mk9c`J
s5^_Hu&X4RZp&4,EZi+m[]A^At!Xg$.,WJ!oP&6Kip@(:u_YCNS_'+.Zbc0nCZ/f7%D);cn]AB
]A^t;Sfa\<=g3;D3f/bc5/;Cr,CIS9oc#ePjW(27/X5<qGpWVN+QmZ-CQ=<)@6pV-.H8cSCl^
>FCEU6tH0!g-7S(JEs*+<lFdD%o9e"!L#q\6JZBofHiGg__7SZ"IV7QL\*4=KKeFP1!P#4=&
H@hX#m_E]Ans4,nl!\\`b!7ra'pBh'q==JZgI4HG2b=u_'8:1G<)fjaH[d9R-/$'^&Rg6-FD&
WM0L>5S>hBnPokFgsg<[13A.e8apjq,;!S/edjjH;Z>gId:It'arHDYPf\j864Us9F5indH2
9Yc,r&p`g7P##T,hW[OB:D(r/h]AXLT)/7^@)79[5>t&Qe(3HJ(bUS.9_+(65uVBupPSKA<rD
#KB?]A;(pY;0qs-\`H%2)?+DT9jl.BuO]ACJi#F%eD9=PLPbK3?>I/C-\>J+=gOU7n`b()Y]A8]A
2BF[7jg]AS>,RbRq-n=)K#M!b#EWa.8k2V`!"\)7;Hlc@"P`2X'lb?@GA*4@Dt+P/jqcJq!Y'
BJ>hZ2NpD$sDJNd[W&<gYgmNZVk*&1pU(H!L=.Ygkol`?5f/AcKNWs9K5,hJ$Q.)6m]A1)LTM
?!\sQYkLL>Q"G/":A5!X<m%%b`^YFRuBU`mKk=r`IV`WmZF-4AO\g&VmNG_I@C4*or*32nY#
,W?SW+D?VAtKi^7JsbM9#>k,[7J58s'<r^%Y@7(lZE;:gFiD$M)KXJR3#qq]A(:=H#-^@A9N$
rQ;JSkhE#1)5S!TH.$k)K!jFi0:AC$)b&*a`8Md-Ddj"I8q2Gbj1M8kZlrMJQ*Ci'nAsMM((
kJc!!N=/(5tm'Ol!"Ca5@l&SSc+a\d2>rQh_acmCJckft:grH4qGJnn_B.F\J=*C]A'dWaA[\
3cH!Qrgog8"a>$8]A3kMp0]AW]AYDg,9Yl.T*bn9)/I#KD*dQ=?Lj6[_K4W(&,K@+VGMuTK!/QI
/jLs=gU?f>"2BdkV@.aeN;":geWNN8(NgJW+!V!V'YL4ZjbYZ,JR_S>fk%!^VgY;(6/dra4"
7t#e[lWp&\1l6M6<4kq-R6`F>$Qrn0sBi"PCi^?V8]AluL*>2ckhlG:c'T8V?^hl1Zm?9RYr$
O*MX(T2]ALd*.BD]AMf\Z#Pa9pSpa8\-"KGdiT1#PFF.IXCV:k:,SSmRebl@'SH%M$5Sr)#^/'
)G0.))Yf.#@6LS(Ti/;]A*)\P?W3#7r_#Sa;k2;:mY*81PpAaXJeZXcf0;HiIXZlf$h5:#.g_
S.a<@qVFBNsnF=n)r)j5jbQ8en+<POse+gql.#lGhgk!$uCq@9]AT"FlBam"NH-HqGYdGe1nb
-&7+'_\X32Vra<Cn)Is7OuaAAc+#eps\i1SZ2MbUL%K>W$Mr;UPckU/^ccg-Kp&@BQpNK1dg
lGL6$'WVTD'7fm*HYe8E<YV6^\qV.5nf)8G7$Mefo-O[]A-aqQoMHNoXZ%ZEON'Il[/Z(]A/'5
RHF93O9OZ'03K0[9U??SE^r[)l`BEbKRDpT<GQ,J*6g7:B%d+9/=b71c8caY%6q`5]Ab%O':-
>*u]A[)JV>;Uh7#KOGqKo(Zk[-:<86YC:GUa$dU[QL$B38P7qTA^ag"G^[G_DYIPRqJR>j88H
F3%.</`[ncDWP-qK+P.q;+:1>GUA_+(oXFG>ibf]AA]A*.*l3L,BcD>A%i=Z:Kbe)006R?<'r4
s*-jA#IeQi5lXjIOeR,p?@p!QkhQ:cY)^?YjkSE(nD2DgKL'9@DZnL*bq^?kH$5]A5fm!q!g[
?XfY7sWiaA0Wju*Z5H8E,fB:$7J<=69N]A!fF"oQoIYA?60an6BSBR^7[NaV1/,du"(]AI5%gO
6uAQff\^Mof`iHS>_9gUOLB2l3l=I(KArKSou'Y<=3dNp?TI=ld)P=r<gSmI$jZ:+dt`!VBt
o'L\.X^sl+tk!"%bTb\`Ai:B6)K'IYl'eeXkk5ZSjANcVYHF.G:6B:?"AXT69@mr8a<b%d!q
L2\0Tu6t(_\RoLM5a@n`+i89jcZ1#N#)E4hJH#KtsT8Ih%\#L8;ZO.3K.5D9YT-&I^_94A?d
bZJ2fqirT?X1'IGDC5>M@T%,V5H>FeXmjd2JS>B/LLce44Rl28(Qi^]AH.lCCFA4Uo\E]AA8%,
<MV!KBLWdI=]Aj]A-BL3]AQtZVdDNJ\t+N86%_O"\_p>69NschkS!I?dST/=\g')ZNDDV9-Ri[)
(,[``=RrP(e)*GD+OaPU;Fs\NG@ZTK\#EXFqVOY[+LF"P;u8]APF[De_O0l?tGP(2-)I.2?mo
ao&%Q,;UO[>IY8=-<Ll=.CV0(.EQ&=1':8=>fFY1FYaLBj/an`^?T]Ac*'':Tefh.1&YgQDnr
,B2N7[3-o]A[hfjsu2W;`V?5\c7?0T$3`h'L6a3Pr[7MgJTgt3mm=<3`I"c8%rd8h2,k)tW-a
n@L]AXH<S<Dlh]AA"i3e[hq>`YS=PVfE9),g8m?OX,d'8=0t!W5)3'Z+DG^-kFMehJB]AlaMSpk
i_HG+:L*imP>cOWgLD#X..]A9Ze0E''dXr@=)=kaFkAjX?4nZXZd64n3`5?2gk16bdsm9uNaY
"?k+$E]AdfRl<quEF')>Q,O8na4Te2jf;:5`]AKP#@mWI7D75FjWOg`O+mDFFd\b1tkKD3"<9f
4!u<gB&a<l`L2E5BmDr52HSG]A'd`SR4"Fj7d'U@q9D4R2q"?n%&[hDWi0i"1d.okQUc36f?4
"=9E:N14";Kpfp_O*B"dj(W3Zm2LHp'UV?8X\GmU`l#4q)rJSbo+u!nj5<1E35S;CsLY)2Al
,H\o&-A0"5@>gZ76K@XL+E7VC#e;ee825O/j8SjG4Vu>11lX<LB"9&=qTLU48GG/)fIZ+;3G
]AqV1#=^a0BmB".bM01/_661Z2Bb;cJ;+TDUskI0U8b\Du?M"d0'7Cf:Pi>Qc2SFDg]A;kc`!/
OZDAuP\%c$G.qmoCA1qsA-T(G+#&(!2d@DOmY9nD=HC&N^1V[Mai:tDrOq&p.!qNN:0Ga#do
#l9=P=dRkXJY!'Za6nIe:u.[Fm=R^u%bGHgZr4khtK8iAtc24;\4&:T7fMY\_r#7OaXeEQF&
)DG6Q*'Sr0IKjHHs"4[BndAX6<d[cN_V/f0op7[0q%<s=X8KIE?0W6`_jX9YI0nsg]ARNQNpr
2-_pI4u/99mnUSR/sq([ZIVe]A^F.dec/'A5[3+eogSR[9/((K]A%=9E&5ej`LMrPJ&\;b&@c&
u.i)QD_Wagt4*&4M%F7HgH#BfdP8i-8GU02cFcbA4BGAZ.s`0$@abnHECb$1*ZC"i2^fXs:P
^(VPrgE<Mf!@+[d1N8%!.Xr3qV$Whk.n&bA&1+)o7V8n^3m&TLg!)D,DIg-dB-15SDf_+C=+
:6A@dq^'&:&(f8;m.0:(,T_MuSC+@$2I<f;0"DnY8DK*LJ2)=>GY2/@VDF;832N`.1(ieSoQ
IUHSjYLTq0)6tofE4CNm>=;C_3V3f]ALFZc+(.'ar.*N-0'Nfj)'s**KMB'iY1DQa+*^*0u]A[
g-3c'9$u`Q'4[gc;q+tfOe88Wok9Skn`7K#clE#76s,$P>F',?G@:sK8m9cT5jHj&S9]A"6J,
b"fLWc8LRu;0!ME*s!oV&,S%V-BS.k!(DkpH2_dSg-15)s4+N?AhLP=;0CN\8CnGp/GCu>B`
p,r01_dLl4;aftnkAj.<U*S$TW'LA"-KMdW59la!r(UkH'5`dn[QVqX(ks-)f`.u+aU!JYO-
&tBf_s3dpI]ATAooKVkE5jiqZVN/cM7)Fg8fcD:X<:J]AVn=j2cj,Eh?jk\o*TkKf)W8%W+_dB
E(oAbST5/"b,d'tgT/%\l\ufb9Qh*GKDC/$l14+o-!"GWF$dpJh)\>!LF?S`Slk+ehT+$haQ
n,Sc]AOPtM6:EnaR*N@8-0V.RkI-MOCjA7hN!>DigU6P(g]AJ,?TpqCB,kQ2?>@=qR29#qYcBF
nZ.-2u"R#"d,(l23S-q=:-o3,B6L@oJ[Ti'3g:uFdnm_j^+OdrY$_Sf\Y[Mn-<J"rP8B&Up7
TYNOpZ1q$"1u<'Dn$7pd`10p[miK8!-F4>Laau8%n!X7JfM>:HqO:fse$^'IiMOV(fJP(/i%
Vj*E?O=8<.OhP9W-Y1;n&1M106$M5BeJMBXjT4I$Tk0KsLY!rL#kSd3LffQ8"8#Du,uXoRB>
h%C?.9ahg]A'l<dSTrk(/ADJa=1WX<$f#%j1aeBDd`T"-+c]Am8Z'>u0&JEFLI>osdF(&Ya6]AC
u1q3A(deoj+h`bH0``>pA5Z,\[P0Q0"3e*TgCf]Aq,^/CF%[R/:\pL2C)keT?_eIE\K?6@I^b
@'N+`h>H@!==K0hAUK8W39;j.[,^!>c+Q[M".5[k]Af__0&UqGCS0[7;FB3MWYOhT_:Rg25kT
_fpe#XhnI!]AT)C;!QGlLhiKJP=<pm$RgMA56Fc6.$mBWqMaiFC@KOQZ-/jIB\1E1'd@5`Gi1
FJcm7UIig<$bMYWpkq?I]ALMEqEGR+;PeQ+q!qr5?DrtaJLeiB*#k5fj3Z"gsOs.1EV:'ER6f
:6i)(l9UgmZB$M+@b*t1h<%]A/M.5'/*eD!"C4)[<P>rLf/0ii62O>/H)d>p(XJ"Y:er9g7@%
5j>)81n>8JAR;:!\#C1n222&c'\Mc-S<ZS_\e@bMCc6?[g4dT3rH@`@FP&:qQSOQIb!-\<ll
E)mBp%S#^XTm@X`H":115f2<^5!Z!=3eS>Q;aY85&d6>)"K!g73IT8SWRb8gEHm`U3)iRM8(
.k0oLBt.a??X$PUC_(Uc0_ACEI?oBAl?92P=(_k^"_Bg#/33*GEGE:@_'LfNFQ"GBfGL;'HZ
F7AoMI4=jhR)eN&*)P$*-IVU00ClIguj2fc0['[IJ=l2a=r4%2nT_8)VJY;UP@I3U`-:I$!'
Qp2'i-ea2([%i2h3*"Zsj8R^mMaQL3t$=AmpMfkf2Lu\`2\%33%Lo\-=%3nPLQ:,<rHE@s?U
c<^*^>r&6--'80>9$%3`DfW%V7.OIdGN?a%8W2jR3Spqb_dHrh3gI.D*2H%:UZ`mMECf4^Ek
"KZ4)/#9r$uXcM#sWOqGE07i7`s]A,*CjDhbCD4<$#!V._$QQJsA:QCbTIE2@po(dXDhnM,=e
M'L(Y+e!_]A<P]AYsOl61,(h)'n>96J-!qof:"l/9J*72Ba1*WC::L`?JWubT;77u'//6"k3Qf
SX1L9Zo:`3BKkZ3s;MW[JFEXQ2\KnpY1IhTeP,4`VY5+F^Ckl^(]A?/+f0Xqet\6/>#.mm36*
:^S'*-3i_Hj2rB"rrsaNL0#CFb'rik3_I7hTbTo.(b_N=M[5[_^BoO9>mEJSD,3tpQ-8soO[
,Z$$&I+,"<dO^CjKjrC]A8Q)fZFWe[o@7,rbca']AXSZF(*EG]A3d5rN+IXB>#b/W11[(o!n\]A_
3MT)U['ZHO4(MX4b5/$AC(?s#U6I=q``\#X<k;ahHWLo^s[5N!3SZDJ`s)tXj=;lX"a(5TBX
$?WAHOpr9pQ"b%p::HQ(*M(7/^A`+SS>_C6U<^\Md?<F!VMtg3)J3ni*>E.]A[T'H'9]Ao4'^A
9%*YajZN?+k18Pko?EZA0^G7@B3.M,UlU\g]AX7gfAacX&ufO))"*Ir)SuGNi_k0G+3_>C*'g
4r]A=2>p\>1ej_jg@=h:/5fZ(%Ue,%:_J%+[BS`->caX?-Fr510]Ap>RR"k3bQKT\K0"ZR%-?S
\48k]A/_U"?R"9@-NID+2.ksp9ResU?P9mHk%9(Sfq"?#^:H0Jli#E^"`X,mHiUPD[.CjlbLo
F$\;Gfohg2_1]AZ&&+csN9ppX5b#p"gX[`4T\14T@N<gZRcQ'6h'H&A-$JO5G7H23t5!FMFl[
P(m+XD[-Q+afe^[%%`QF<OZ,%/g)sH^Od$h%cCg8#%7'qJTLKl@Y7hI,+eZ<esPH<ooN\T;2
;)0Y^O07V's\L>8<McoH!?c)SNU@\3FRIk7qN_O,[hHZ/hB8CJHI:SAbuN`p?d1m*@^t,]A(O
TnKmBoQ48q4]AqJToV0E/2%$Z(Y`N#UiqrK:U?Zbb!kTsQfg`L9j1+flJ%9RqGl(0Q.>fjM@:
LCS9GY%86FF:%\Z+OM-n\-Fkoh>U'TXk]AEe"6b+C!40X]AtL-)]AH7*?V9.uC\1d+?:4-D#+f)
Vm\bAEqXp912H[5,FM![/Gj>l,W+M[\eWA`<b>s`Q$k%XYa,"g^;ZdMG<-:!r%F#D6=p%FMb
#bu4bZ*=.rL)gYr!<LPlR+_9u+Q.<q"mism=N+lE^P-),j66"T"CI26nujH=S!YQ5)>mk/l7
)*"C6s4+^pa&#)#)A[;cR3u\taR@0BqXL)r978Q!&\0EccHrW'(,O8O&4R0;[VVHs:Ru68`*
3%J3;o#ZNu(J$=QFZaPuk^E_!hDEDM,#0B2WJ2ra?F7h]A-rnAk.KiLj>Vs8)t5ioILUVYK+H
H]A$rFlLSH%GLF5Ln)cY,Q0`cGGNR3P'UB0)?.m!BY)(>aE5QfnB2rk]A"jFfZ@,`+`?+s=\O?
9_0Id%DJhQbs8:CC`;hKg`@*9liZ^Me>2Fb9KEO\f.IchG&_#\<OMs06cI,(.#e4-eD)=b_3
/Tl"-A!0f)a'H^FC5*F]A-)EF=Ci73-%\Acc*[kR%.n;\HNa0mS4DI/V\b^TM1ik$hc/R*HD=
((Pc'WYh0^,XMVJed]A6su!H'rc,(;C=t*R^DRT9lBl:;,nf1a59h8oKf:GfkEm%?rK@9FJ3D
A%oa-qH>lg!4GMk2B`1F1^;-ZkocBL\e;;SV_4CIjYH2H?2f_g7"cR2hnTC5A=?cHImD=uU9
@.;@F-^!I<`62u+J#k9)#6/gl\VJnrOtgj]A<1j5Z*9FPFD8d^.m$0H__1_@>-p&Bg4<$kgja
D!ghanC]A93N;]AP.5foE(>V-W1V-53Rc)Hf#'H<RV-<q[goXCUYeTFQM%FLdfV53R%pu>^k;u
>.a^X^i*2#<u4tj!Xm'49-Y)oHAp@Bj_ps+&/2b\N8Vf@kf]AmeF<Q:)+<H=>\i6Tp!srTb3I
]A7cXAm&VdFmj:GBQd$55+E=QeG;%l@SleUL@K[2VKelZ[VA(iCd0^Im`jmR%T8nB/WRcHqJk
\54a&!="^^`H9AX\&#>Iu'RcZV/lEXZ>s?(#4#@;Z289tV119%G5g_bp+^u:FdX[mJIB9qRj
_3lm2)W:,r=*XG?Hpn7V$>GZ#8%o?<_^_tNY-:dOu.iC![M7MT&n9pTI*siJpoKcTim4\lBj
PE?>1&n9/^1fZ..KAh!<+.K$nd(^!EK^cCmor(kXaC4.!R4eE4&#B]A\jP8V$(d0WjZt]AU#'.
]ADq0/p2j9GnF?7:JAjh'J8P9GHG4W7hdp(2or'sAZ'%&Wi<tU1(l='b@\6LpfkMS"j*kYn9-
e\p6Fhh\ACX@(^nq;P'2BA9T8H4S3.`T\$hI05`^9R[4EQ^"rIHg[U:k-el>5Pt(iFZAU$jK
Q^&FrJ)[m/l\8.ENeiD7p0ZDF<2QS>5lZ:XW1Ek&Tdpba82UPGJ)L>^7Bse+3M>HRR0Fs(lP
FEh_D&<#`i)1d8GbG-JOl)a4II5b7e_mU;e8[/rl:I-casZIa]AkID"B&Ruq=5p2HcuR%pPZ4
oQ'mclp:mF?,&lt?mes__H<J_(dgkhQ<TmkS;RA;$l"1ZKLS*%F=G,>4+G!DuiAgLaX$9*<=
_&@"X??0k<Ea?o\mgmp6KJ>>KAS299J58l2P!=\D)9<BnC?2(;=h3G%?Ol/-q4,ANpP6MWad
mBR'\(#A%7an!;6`&=KVnPY_>>MEZ;@m1JBrLt9Ekgcf*LN[RuG@hogF.dDQ''Imqsfre"Zl
lmS'KX;VF\hlU,o<!D"Y)b:S"UWeVft`Nh3CWC9@E'VIGj6j'_6\:n2kolDukNdn?7/[Q#G<
^^]ALqSLa4r9#%Z0f1%I23<SVhm(!BFT724265n`@_sQK@]AFlX2LRheMpfNM(2FB-S5+29T%&
EN)fr3jfI(Q(9`1@U?C&1Om'LBL$K,EDbQ*CI6l7)>)eCJ%?+ZqO1:,5Z;;BK$fOJ<)4h*:B
'-NM?YD,*`YdBN.KS+HBbnI)F4]A-Upf4TgLZjiH'V8=="E$.aTVL5,K'.F?UUQH3:&Df,c\g
TXFafaEOnJgV@\Z4c4C!5GLC**a%!VoOPJfFq+m6-^Bj2#TM-%WneL;LpHQ[<25Bd(jI":.U
m7D5mhHsS_!^#V-Sa1[nb9cr&(anoL$7:Rb%B^)!,V*+EOKOG9]Apg\fY^JuQiA$,oe'I3Odp
^I]AK*@gHSl6Nl2SK8P";_@tDCm7%4:]AZ`/&GcR))sD^,9_Cr`R$Yt.k6K4M;9GWVKct^WF+^
,_85.,VV,1uL8:Z.&_Me6N5l&I\Ti:KbF-0NMWl(aJ='3d&[>B?(.D.<%/M8BA/pN(g)C%Ar
^SgqO!Peb#jmA\`q;\rfC9\eBlpC&S4$H%!Nf`?>ac35A[q`TCdMJB3T4He*nqFof('C]A)=@
=<k^mL4XZI'=Be5:?jm0mJR8*<c,'6p!0IlrQ9V9%7>3kV++afXK'.qM@!Wu=Q&qpJ5$)A,W
HYDZ3+Q'5,$/J(FPVm[>WW210\oo5\K4%91n5;[lRA6CP4eHu"r]Ai%OWj,ZbU%W+aKP+f>$o
i,*!a,CS]A2i'K2DbBa/JNI1/WLUp^"L10jcfn(.\D!UkF@#mHQ_c)h<NB-K/!k7V<8/^6;tR
c>pTIS+!RGZA_M7PYN>M;8e.ct)1ea7N1"[ifGRpM%Hgc7;<q\j(hcgMJZO6jBk3=oOO9I\J
Dc5W:@Y.H"Q7QYH2<%?ogQR&df&"G2.dHZl#0R]A4cRs*rd@27JlU\XJ`l^91bfA3Yi(,@Ca<
FoERkCfLJa'^6V378(g_,+T!QnlI":>s:/3gPOOC\=/8\jSD!BAa!/fCq0e>+!p@HT\LeM5Q
180IFsSt_&&)-pGU[ii^GZrS6+,6c?;f8pl7><('?21LJTQf:;h^)*Ble>q.MjtFJMl<e37C
7>Y"G%]Afag]AE;*8JHK0aej%J%u[Hi\neE_m.a0'#YHTs(^2L'gE,/5T#t#CUrM<c)^7@Ae-M
eG7TP=__N9a($LG82`"EhPI9\)JB:m]AUQ3"iMJn+Paj^^-[A[J9e,#:ZH%%R!^Dd98:k_kTK
FehXq22uAXWg.*4I1mdS["5&K_p74,2tUh/bf#\;j]AN9rXl[]A6&Vm,pJ67[g$@0oRTu'lH\p
*U=c-PbDFtXr`cf9$Q:kS(E@RGaknU9,B.J79q[%7jpfq/:4@qF0eHajb)dVWDe*G1b[8d&T
,4eSjQ9i*C5k$JOa+lgSh7lF5p.WB>pK'`$Z-!<0.Ui[YFQOL[VnA;D[$1ChYNt?iLIu]A>67
V<]AjSo=KP1N?C98W9rtD7rsd=WWi?]Ae8uQ1GX`q9PU[9DZYROgakh\g?tnJI=n*>6U%mGSG=
[-9F-h.'Kn7#H1-(EBNdiiIT\uDD&\hpC]A%<ST=1<=R(lQY/Eo-33@@T_(PeiBm(5HH^W,Lj
k/p^M:X^$Ccr>)p!^DUKA3.-nSUQFlmP59!4R_EH+S<B;W&V%YVe<Zc62KU;'ktsbhc5D,pQ
]APGp_5S5#p\TZroc7u9I'WK&Y("9c9?Ms9jN.\4:R?[-uE5R#eN&INJF8^r?%E1XrL(oMZ-=
T+DsQm&qVbqE;XbL:>ML-m"Or-L%(n%n1<;0fcPjhZ@hEVKA!O8+/U82*P=Yf8j`s@,6U%"M
*omOD7ZF!@spnBQ<e#a`*3kNOC+t\m&:>m8ng=j%8R*#*AOk[,>%-"`snG6\-3O#"ELS@nH$
i%ZQrFDn&qQE7LmQkk<&b+g-]A2Eb;,Oc&UioH(psjO?5:kO(?j#WD>*.L<78n!B\"G/>^`-h
qXSs!R;_?7gm_JdnW`$el9\p(8"-R!N>mkDZ8F:**nMIX,8ss!TLU7`-EgA#fFaqXF$bsKG5
CC?E4&pY./F:V2IrCW`&ND,rimiUa5_)A\c:=2:DIH)@i7d8V\<7]A9:B@,Xb\D-@WlK[C(.`
l)Wb1FSn?.+.0W?VWl<M1K8-?E@>=4+mu`cl54a3;(e&G>EI:?FhaaW"X?m7sdi`\*L<tgZe
fG=e/@>6>9J=?jR.$W:M@>-O7E`G@]ATXd*TWX&!;;p\o&`XbFUcQS+f$^-[l-u6[c3N=A5,`
4BeUg<=1i!c$@?=("'P4epg%AOfV@urt6GT$]A&5R>=V#tH+6:pFjRlN3?Vj-J_b>r8s`(>bt
MmH#X1mUt;Q]AhaH7,G7E7dAY[GW,c6!chQ(5V.&2!4MOi?R)@>9CKQa8S]ANL7rY&W_o)BS1E
.33<`P-H`@qEYY36k"\aH0<Q@@Zj8V/C0+fHHgJ0HPUU?W7aRrHG'C0&'gN*Rhi*X:7_GSjG
*S6gH/"hJY#\jEUdhX@IHNi.Lme15l+0OY+`'9;,aY*q/o4\R4q8qUkJ5:hamN$0#f6TOgOD
2YC]AkGMaA1!a_hjdWn4Z^'bX:rT>Q??aq+s3r&$QGP)>0/nid>o_K(.@!Wj]Ai#>=1SuOq>TA
,3.@".cW$I:#a7_@MJp&*O'Z9$f1c1W*5$1&j%h--MXD?sg3opM#8`rM'_`OWO[HT5\&d)(i
R]A9Q3=\-Kt#VcA+Te^GsZJVep_ZHsE"i&(LlZ+@]AKH08M`Qj;4gN3.)N(7I+F^PY7l;q>#Tu
*`XBG\>8(a@@ms%SuNVu`ub[=@p=h@\A.BsI:CM]A-YmRf--\6F1nSW'osi8t9oOL10,1!p9P
`cfA$7dD<9?Jq<//4rG0$X.@_s+hkBpiLV.DY5QYdDC8S9G3+$/E;pusD7k@0VbH5MO'[HZ?
-=hHiS#&/32KsiJTa,2JB,OGVft=#N/s4=Bf:*BW+]Aj#G#,QRbqWP@fj,t5/M(,H+Hc[%+Cj
+.P:lrgrlbPkmPhuMr5_/^n)A'#@A)FReS#8_o)(Ub=IM98jac27le.HA2i^A>R-lPWC<Yj7
^Bod9[Lo#Wl]A35aCr2i\@]ApD))`U=RcFW]A5"DA!`L:S&1dHW]Ab['=%2;'R;qY\D$<EHt,E/[
EMnk#>iqX_khmB-@368gW7iN^_HT7roMT>iB*qe=s.2`Z5GaeZ%[8hOsKKEE2!6I61BR;56J
p#Xa?F[N!f`DP`5:d4@&QE02]Ar:*pj*0fg*BVp4<6>"JGDAu[X`,t1=pJ2c.T3+\V]A\8EJDn
^.3@<-PaO8WUa<,]Asd&i^2Q1?Q`@'#?8D9DM&3bpfagU\XVNn!L8<.-ahDn>Lu>:<HmD!TC"
8kReuJqFQc"3M%XdcS2S93X?9%R$Y3PP^Tk.LjFdFL5+ARMq$PiZ]A<0c8^$fqp_3[A'V)R,3
QB?Q.#hu(/J=q>ORi2m-Tl=1N;N`NRQekWk%=%+rC=%ic^l#t.FY?8b>BKJ[`N+>\)Dn"0[@
FPGZ!4T&m)&AqC.r]A^n*h'd_C<ajcOklC,M^%S@R^AAdVXen$*RZd"17X]ARNT*s`Sd&:XOh4
K%:&#$Qh(a,>Lb@NXW2[j$,i"$S)\Vp.-'jNS_60@W!-68R.Cd;-\RU["qMsC0`$7/lY*Sf<
#J:n^:Xm0e6eB=>QIF`-6eA6,a#Xlhp%"Ueec,<GuCbrGb#?M#u8^[<.:XCf=m>CQ.0o$`8"
Z=_5/RgfO^]A<2BZg'Y,,8XAV0%;YMqlSleXe\d:SHj]A0T`iAdNliK6e9T3R4S==Qu83+nd8h
W$#AS)I6*kB/Ug:2Y*^C8Y2;!$uHh<;/m)e#c1Pu;dY;'WFlo&&]A_rj""QSZ[dj2o]Ap`03ME
@ktHV,o+.hDNe4B5W8dSYJQ=`oeBL(1W:PFM0r3Ni>M=j5P$,-6jV5HQ?^p\t$l]A-/]A$<&rt
@S56!0"Ll:nJWHYZ0NcCG,)q#SQhk2TC45''U6s>:<T=p%bS[`;@*JEZ)q,XrhpM#TftXAec
4X[KbHPoBk!BM"a/th=@^bJ)^)2N9-3]A"GcXf"[6;n'Ifg9"KYH5.;!K*m$Z3VfFURhj_B,Q
%#<*Dq$e<IFnHOog`=V:upJ\AeUEQ,L]AAE<fpn]AI%aFbj6E7Bh69rM^0Cpg+'kCrn4hA3N\&
+9ng(WD@?"Z()\6&W9R8*)'`+MRc&_?l1aEni4TNT/D]AjQ2DS`U0L0h1tm[oBAg9LQ#gHlWP
i"D\KHsqfNGB8C(H<;d5>:[4>Ugca[e$@hOe><*8;`fe=I7H/g3L[2#a.Z:F2d-hR.2$_<"R
&`s&Hk77-gi,E)@uVbr'$HA-[h\Mg1Ed7mO)?(R>$H2kC=WF1P6ggo\^f75/Vf*4mFAg!)"`
6X@mTX\+PQeQckfiYkHZVH*r'=(g!lYnYJeSV4im^ChG,#`t9`GF<J=agNE'DI9)`QOQQ9P9
6>lQ8]AGUTNDH9T2rSPk-hk#`;(,+ll^ESYGAGX%:"Zcj,)7]Ag6*ZZS@M^*(X@r&.tMm^>T1j
=$oGRdmu=Tm/@d#QF*Vk[A?s4dE$)H.W6FZC3f"RAGjTWMgn<6;ipDm#nu==gL9a$e\2XRo#
oD.j1nNK'm0U%?dVDB)hN%bKIEIq;]AP[V3c<St*U'qORd7?&gJ=aUhn"\FX!t;mIrq>`*S&/
;h[`F"D(ZgY_9<NX1"oc+72]AWepo/0X5p?6CFE4TL)o(`X(M">8FuOB0R)fL4:hOF(e[,2'Q
gU8FPc%U@^2OZ6RnX8=MTW0p.?O6@k.BD"7Co@=/,!Geg=GO[E1)?)-1S#,6:5&X)NtgUK,O
hTWCZ7se)@UO4Ge3+)E:*6bLef8^+oDJ0R.%'WbH`[/G$O'+cQd*KoOB`E>kZcPOb_:`M\l@
9`=e<dsB/9Q$:pNBhG[9M$-8a`XdI!C&!67C-9CLK@)N0T#8sio)fYLfi3VJ%4lT[M092\7h
OD_^ZJ0>LS[5-Q<u(!08k)@,ZX6CV!<VK>)i"\R)N\=d"2R8^/Yb6)V78H8Eq7`C5V0@O!qu
j!-uj+MomBW%#]A'A)EpjWpI?E$@Caki$6J^lF4:#2!dU'1Hp$Gp-K4Hq*]A\+7BqcI(4PYP%0
W4).@ZIhVcV:k3r\YJ=i'D<NeP4Ne)c=O#?j?InO`=_B(lF'/Kj[AQ+X2Vd*ATaN)\cK>7:-
&kSXS-"SuXO2Lm6/X0@[QIWJB12dYO[5b@(04ru'4leV#`18Cao]AS+n_QqeL9fQH"/$+\40d
M+rJBV*It_c_OL0m-Y4oYECcDh3.<ln#kC#=baA=f3<'t/2ltb7REXK^ElChZYkR?7((Lna;
RNKE[N:nh%@k7drNncW3q2Okb\1?^9&e%TT6d84s#8E'piJPZ8'qSFTusT&.$iQC'i3I)fO-
PKJHY:o[4`^^+\KMhu(<_%<?j4imq)]AjG('Z_Bd%cg3Rpoju(3*0:;?b^FjA6==oa#&@I)Zq
'@)b75Rm;!qfe1oj/QEK5C<X=[K`pQqH&]APS+"BR1)l*oNu?732Ue!L]AFoS#Eln7R,Z<I[#b
I1Ymd#kOehj'5bVS%%L]Agh?aGo]AW#uFs@:RS0A*)4K5aWlB1Zc!_8sT%u!V<i\s,r4kV(TrK
c]A,gk-mWqB!qQi.k8dsF,en&Nd^sSA7,LmRcA2AGrOTd"dA%R6W\Plm8]AG+mEaQ7+2EXRr$@
-i2-S)QK#kdN0e;F\uqeD08AZs")))JEQ2ls(YNI/FC58:;qKI8T_a^$ItKWFbP6=B<Kr\dH
PPgOQq=G)i8AdL8%5'MpTe#\GU]AVH3Q3VU)PWUUe52gk8'kW3hK)[saDbs,TrYB?4uc356uo
bL,$q@Hfd[HkoL6RHX>Khl*0&[Nim?_1VaVo3@UHRd[RH+t@'U+&$UbEamQ\I7WKT=<E*(bK
kJ<ctt+P]A*[JG!B(4+>pNto`eN(:*L'W4o]Ad!YaW2Y')9Tb+cG0KZ"`P'XWKp&2gB6ZQTNnD
*FI=P?g/-Y*9=YD57+hAHlV8GjagTd&:#FjcmOr4MOG5L0i1-k:Qf8>2YQL-e4MG4<0j2e+K
)N,k#1-jB_@)29m?at/N1`n4*?@sF=$&<V-i`bR,hSfG2<W=f(6B?9UBBYPg+\]Allfe]AQDYr
`IW2Qs!.&`%A:e2q[X:FhUqF-E;,+A\fYn6O?L`Brj>B>GP;rR:GMbM_cC2Bc]All]AS/ZBA/I
4hD;)QDj:B`D[>/S.]ASbtP7,AlJtaV4=DgcJ8*Aa?03^8C5IBrUe`]A:7j.bARR-/Qo`MhYDI
q^+"5Ln_@fA<FDR,^i0ab$'"lIGfn;-1$A1O\,Rb"j.P78HO\KWZ[Yl-i*eD>M;p>r?E,=8#
i:eLoc=MWkS:QW>Gd:S%VFkj>/?+FsWlQ5(*K%L/$NF-V2(aS^np@)o]Ar_il#a9.VF%AaPnA
ZCDK3f#;?YG%pMp[SrC_-\QG9%BMT1'2&On5i>ps0()rUG?MeiYbpM9NL27&k4]Akd'R\N?<;
G_%rsk9ii9fHk8tVC"Gs9(#:FBgE2\[jQi%oFt=#l6]A3O+$_7q%/W*J,dBhpqVi#<cVr+l4M
C\22e/m[O*otkmb:Ioo@c-=%_?k,jP'/`#h_j^j_#jhd:]A^(YKPmsY@*sTR`Z9IZK/B1^r!Q
7G<WS<mFPfoPQ:RdjcbO;fpU^-Gcc=RNZ@>W.q4_a=q!L&jd!sM=CB_8s[(=.4rV/K9k,X!I
@<kD5]A-gF:JpuTmA2%]A$JQQ38>CBs,(agM0X5mUZj*pWtNdt&=2bCCl!j<T:U>A8$CAFd1S/
r+6lV8he+8:>4MgIhr&g]A5^KIDi-LVg]AYFL;5tm3uZRhTYeWN8AX.Rbn8E6O2fV`]AC#+d$cm
$Bh9FX>s.!KX`i:;hqe2fHSk;q*5NsdI;1\UISZ$KR7,B4^b<54>7a,)jBU""DjGZkaUHo.7
A%X7m(JM\%)/NtE(uM88kPfp!0XNY1^p#b,gaIc$Glskr&B[/6hu;7]A;r_VZ)coiHd=l5WTs
td$=5L86L0WH80?54"cmK;LmXQ$Mtk1bA)rd"+oukk)QK]Ae(<J[_UV+3=j/Q*&a"E#EcIcnL
iH<:]A2$@Ht`-ZWoJ+^n!#sK;sML1/C^]A>rW&1S"]A8#QH6GO$4a(%R4&eEFJ7X[dlgciB3*o6
Jk&RNl2D6^J37V=?qas7gmYKW(5,6O8@HI-;MqF3lK)\+,;'SLmtR+04h__p?NPmcmN%0`Jb
Mf85<1Jtiu#%h$7R5Q"8tr8d!##*/1U:/V3iOVa#kJnKRf)NaP$_HZs*+t4)h.<>+&+b!1N$
/TQH]A7TJ3JGmh__]A2?E"!KUer@q?r9"!Ab-Ag)g\a'3?k]A:hl3GUs)>ebKd2=l,s7K1b;L--
-^j;<7:1tD1;)'B';UL&*)#n_o(k2[&%]A1=(TcqI>NghCh?-.[Qc<X5CH`q.Ral+($CYhf#G
5mI68A2>MI)L%XK<\F)8FX(m9Fq]AI0$PP=Ul[G;:R=;XQ"8@?K;6NSE5;<*sqZPU8A2R\*Q1
"PCo`.EkIT?d>qYqW~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FileAttrErrorMarker-Refresh class="com.fr.base.io.FileAttrErrorMarker" plugin-version="1.5.4" oriClass="com.fr.plugin.reportRefresh.ReportExtraRefreshAttr" pluginID="com.fr.plugin.reportRefresh.v11">
<Refresh customClass="false" interval="0.0" state="0"/>
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
<![CDATA[1485900,723900,723900,304800,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[1440000,4032000,1440000,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0" cs="3" s="0">
<O t="DSColumn">
<Attributes dsName="年累计销售额" columnName="总金额"/>
<Condition class="com.fr.data.condition.ListCondition"/>
<Complex/>
<RG class="com.fr.report.cell.cellattr.core.group.SummaryGrouper">
<FN>
<![CDATA[com.fr.data.util.function.SumFunction]]></FN>
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
<C c="0" r="1">
<PrivilegeControl/>
<Expand/>
</C>
<C c="1" r="1" s="1">
<O>
<![CDATA[本年累计销售额]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="2" r="1">
<PrivilegeControl/>
<Expand/>
</C>
<C c="0" r="4">
<PrivilegeControl/>
<Expand/>
</C>
<C c="1" r="4">
<PrivilegeControl/>
<Expand/>
</C>
<C c="2" r="4">
<PrivilegeControl/>
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
<StyleList>
<Style horizontal_alignment="0" imageLayout="1">
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="4">
<![CDATA[#,##0.00]]></Format>
<FRFont name="微软雅黑" style="1" size="104">
<foreground>
<FineColor color="-8595761" hor="4" ver="0"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
<Style horizontal_alignment="0" imageLayout="1">
<FRFont name="微软雅黑" style="0" size="96">
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
<![CDATA[m9"(%e(;%KC9,ohM`;K'.u5MZ,,bVQ_ehge@5<?U@oN_i#Ur&)$q\+^=pLp6(^*2W#RD';":
/MI=p6&p#a'cW+BBg4+V?JlM*-C'^%\Z'526Zeh6l*CHopN+cYoG^cQ:AMs)4J#L91FGgFj!
E%+`%_E:Yq@ptX<5@-+@F?S$ZJ>ZkTH?sm!ome34Ojnlo'F<^i!p@j6145Z9ms";=\62#.Fe
B?9in)7Q2<rYI\ZJC!\b]APpmp3WR*)]Aq5QRaM(AaLlGTT:&4GSQ(@D.^s9lT<DGiQ,D.8Q!`
"o`'LZS$=AglKc&r73-G[,lU76W[`,;&d5-ql78U]A7doeE4lKDM0f+j2kq5\;$q7?`aYcPgK
JTa!%cJa6_)dWW8#&]Ao1#K^lBBuNKHg/TYCk8VX]Aa[:6mk5!ZP='=-9XXMtlR$mJmIO]Aguc-
JD19(>iR(=]AI-.NT/M9$(c8cKo:*Nt`;f?"UWl=uK6%b^$&rdF(Tab1A//&`lX2=Pk?d(\Q9
s!jOo!'"9;V'.JD`*!?)<hIW6Xj0/P\GSa-LjIk);PE4/7!m@BF)U/u^U'H.tiZUN_IlcGO:
G(N=)3#gYUR;/pe2JYCN)cu.*JqK>:eL+sE?'6%mU;mX=m&@*BD+SZfFR$?`X$JV3a;^5PuL
P8Y%,NMpg0H?2UuUpL_1:IcqObf..fNNmuc%FGoW08@e!Q1OCEI8TB]AmTaAu=HGM5umF&0@b
a),+lO)-[,dlD->F/^9:>.X]AQI/(;_U((J=]ARO;7pR:qQWQZT_<_saB#A&$aoYGDoX5>1PS.
jm,E@KS;pHuRc/ndB6ZbFaXhB*KR-;2@-bn%E#NMTY$hSM'c=EM8^>!$g>cnqRLQeo&aF/uk
$qb(NnOZCq@p09X3;N8"2drj]ALZ,aFR)U(^T(cGKI"XsbuRftfRZlJC;YN+L@;U\Mu+$mS$(
`)EZbM@K$0+Ob;'X[$ojhaVBG-jW&BhWE%H%FP+m*&8SetDqNWd]An%=np6/l9&-=8()`!Pnb
Vn)Zn\6I\rDs2fh.d7lEVXj7=qhA0kaJ=a6uXV'cu6K-T)V\1_jf,'?rs+;VNkna3aY42N$o
J%87WYiHUfE4JXulS6PYd]AkPM+dY`Im9ik)1E]A^/?"o0(-:W3n'RhlleR"8<qr>2^Y2!1@b\
p>oU8j@s8Zgs8&(m>DP-NE<FmLkI3@d,W9_?D08m4igTB^P;&b\^O"I4ubH*m!6GXSTXpN6[
T<TlTIGLG?/?X$bD7Rln#L7)fR64:+q[orcNluRcPFEV15G&/ib]As0\_kDa9kKi%))-6HQ.E
YPuUd/:R.J]A5b@U<<Z'i!UO5iO.*-45l=nH*9Nr"u`_WZ=AVf`m#KCb@nfR3QW=;3+ss%mrB
gZ=(K^`(]A)hER>*bL2Hlu2@<p<'kVcEhPh8X+?KeeBqP\$Kj?8,^=J,4>P/f$oB"eCW<%>Ng
Rh0J'PhLbNi&ZH%L4*UQc)Hqci]A0?na$:OjlCJ@MoY^'LFHt&@P"<EahY0X#OtgKb%,>WueM
`"u-`<[?*&o[`_6dZO,]A)N#p1Lg&h9)u'_B*-7]A=Zmho/G*Ve'8!>SVu?jqn#Sn,]At5kK]At[
SRm&hL$EpQ9V;tE.)sE70;7CTXkj^;kN4K^nU-'4U5%RTZR59<`"mUD5i1;T8,mQ6*#TG&gF
J+[I?S2d_[)`cQLR#D^@kYl1Z0*$/L\b15o-[/M$m,^^a_@mqM#?`in\p$OG]AUW@,N:*n:Jt
\qBOa">NV_4BKuX__0"im_kIUbo^29<eSa!HGL:jD]AM=Vd\C`!<^VKb<MaC13UX)S+-6Xpqf
/!%>B=4@k2A;ice)SHqgg*S9L1jNdMnK]AD$/4k:a<>Mh+Z>->JT'IKaO7%S1!5K%]Ac]A@GnEX
,6]AA/+5q6/HD9p\HE&,]AS8[Q3+>b\k;3!ngnd$XnmWo:-/I0F<sc_`3*tE1PgdHi%rGRUpZ4
1o=?*KL*O#*gn@G-=&[/<qqc^KAT,d"HBf(L4S5K-plQY$TmipaVL:0)kVTN-[,^NN)ac?mA
@s`%ZHacaNC-7TNYKHkgeMgi$WutkafmE$gtS"i0J]A@CFX\fF@MVt2VWD\QZ4uK2<U]A]AFfLB
.onW*%U<%MPMFFO8`e@-4+?PO0gYj;_[^RTV)iWsTs]Abl63dNG\(^hqs,+X!K]ApdaCJfgA33
4c-oik%(-n:;H,NHW-[4$]A7e$"o/m9\+A,<:PVWH*,AR`(J\0$L?A:h[QG;/.Yf2tDWa:%':
!R'%J@7`M*ACiei<l.>(eY#dLedhcfM/a0/lLT6#V<.e1keY&QfrS\uNX_.'A'73]A>p#plnF
)1?@59j^L4Y`)TpqNU$u(XTN$IJgPj6qn$"fmK6D&qh=jr2VIq9LN#EJ=M&"LF>d\1,YO]AAR
2V7-AIc>_0:r1n2WQchaWpUl;l.N<T;8[+f"=.Zc`53-1c)a^jL1SMjIe/'.Bb9RIB6@&iq%
[3UDiSM53mVDh?r7SC4C(F7m=VdIA=@SR*ab(4D,E2S!0k:l_8:Z+;R:!BkIYf(,!AH11^7b
X9RI6(TMZRKUIQ<_>,b:o2D.P,Dm5t0dU>=@ZbNPfQKg^i533B(*!6RR&.@Kob3E@r+4Q?/D
M=b,k]AiCM-gV>#Q2POK34,hr-Q4/E6S[[EHG=*dR1o<+%87'!6XIklP\enJJ?cD#W0bpqS85
$o<TT0T=*<8EQ6cFT9HK"7KQ6.<h5.13-1/8i[9i59JD6d:XqB)b%]AC_?HsLq_?pod&,FM"7
'.2>ptu-s963(8a"::9C-@!JfnrmCiEp+GoUR[%Z]A[TITR0sIeD(_2jl;QGin[H.Vaju.)V&
#9@=OB?[58_$/#:JogIgu%,Frs'*sVO@J@1;Y]ALI2a>+4PPQ%$iiB9L_Uc_GNc:&C*Y$]Aco@
#brh)!cUPSQ*Xd=7%IO3GUlpUer&$B`fP<:2gOin1KDF07Yc8n\OJZD>9iFP\Q`1(h4D2?DF
7<,7pAX)4qJ#KR4dLWA&upQ%hms%EkG%RKsN;5\uF#VW['>j^3s6CJd?N>BH@3M\1<:DX2X^
V_;o?!QIeB\_N-r,bkRHYrR-a"ma/*]A4jhU_J=m3M;Q.D!'ZU:8TcIj@dXE/'QjN\g=2s9'_
o@<rEQ,r8Rl6'TME0,k>Wl,G-9O8Q\LA!e/VZ&i?0HJojHo*IEk?tE]A+A3gCCJ"TKdaSO;E!
kOOt`k).j"i\<?4=T'\T3LNAh?*@iud1Po$p"'\>D;nT!JXZ"S!/K&"X=]AiATD2TJ=,R23UM
W9HRODO(hQ[IE!q+,nt,2))*i.(VQM7C/+&#Uuc(Xt&@U\lR_R*`$fE[+2Y#--#&Q@<Wm*V#
c["SF\si_H:6,"lfikY)UjAGf_ti>Eg@hlLkM5o/UMmHnI40Nf*g4la^-Z=d2Zr_edZeX1<i
N-91BT$kZSs-D/BiJFf?L>LHq]A/;;g)K/C422pFe_?T;H?^3E?ilMBtCl.+X'EQCPHr"K]APQ
U1L0P#KX+^*VF?Q;^,>G'Z+?1#(Al%l`j[<8&jQ,IJQWWBC:DT25qZRK-59Ue$6Xn_piFUkK
CiG2#r^\O:H>1$F[2q#`mMDcr8c?K3gVTp53_njJJf-H'V.g*+$XD<Pa1k-@<="8?jZ_2l[g
B#DQBO5\Ps.%V993<,Zq"BnL_cNi2K;pf"))AZ=^5iZ%a7Gc!`V-E2*^"/jWPuPjnN8/2c_+
a;.=.0d7`O)$oFg<[WWZl8"d\iroh@ji#2*aJYlMm9d?u2mE*!brb]AZ\4MM\(6igO,u&8jb5
idp>!D`4VTh*=BTs$4ra9j&_:_/_F`K.M)\-iV#s<N[V:UD4F<SPiTmhdt6QP@f'm($u0>s$
M&14)1/jqoK`%A:>E?/F8WPm#-fQ$+-Y*Wg/D_>?JO[p:9(=6Dj'&_ET_34ECa,lBB@V!USW
6@(D?-fY,UPN3MeV!O6e[2K$"sd3;CRH)lb+\o<RcWZfCJJ(/;?2]A;rU6O[&d@_pCl:5g:09
'g%?Y5KpY.06Fg72=YMV5M$W8df-!>fY@=%QKU)<Y*6;'1.:XPceM;DHVC8+^#f#1Tsg(u1o
ITUd&eWs=Z9,#fctnm;&&R3/Oem**"%"f%hu#iCg9KnCTckFONjM[3E9@UHqpFDKN(U5h>7g
iPR4#m]AHpa3c&+l<FI)(fM.`MX-XSV)dO..GSZ@uD9W)LiIJUn2<Ea`>e3hOH0c^TrfaeNFl
s>f9FhM;4/!ZNj]Aqg$^q.B5_*O[ne$<!!bcP1dNJ$q++nKarq?HMb!&A%*%rjJnYZnof?-p<
!Ol=S*1Ko1fagIG^5[A"u(X%AKl8uU=&BQcfGP(-22T)\!(gun9d?I*6oE,&XRF3#M/rY57m
Y_:]A=Cr<@E7pV)-[e>=PBY)F)28=XH8;RU):3l#%JJ8WCgNuRoVaZ(TQKJ*ZUP(T#(eDa"RH
?JY1]A`:XZ6!=h'_\_?O,obGR_VsJ>#W;Zd&FY;'+RXr/af.T6`H"Rb>3fAL)ukS&#j9@_&<f
Q6YVOO/\nYCq7DqAbP%="a3r$a3m`72i2+.bfXQZR;I:+_dj,2eYY9ET:6?koi\r(n:a1!(k
1seGm-GCZT()BD8-uUYLUttn=#*M@Aa`edr);G&?WVAd>[ueW`U^('^mi1cS$mYK+dI&.a`L
R'@FUj<%=;6GXV5cg4I&<sqko!o(Z9X:h]Ae;$("m1fD,SBSUQfa&MXN\c8cgi7?tm:X!9I3B
&rk)U_:`595jOb'^17YeA\4eu694RBs05"5LG&-2W>7D8qJp\1[rX#Y^$l,^rZ(o;4dJKi2n
e1^_j+OYom'aEE,7nL]Ais+&rk]AYId/P7).f(QrD"Y^]A`=3(:0G+5Ikm:'V5.`F.9'f8]A;2`5
HPF\G(Otd9V:3?a/TdBX$*6'`-D1uO/SbdYOVU\>Im0AooDYmo1)btuK&5F-IDBH_j$QA]Acp
#p#5=7NH!Ueq$.s2GhtkTKDtb3&.0^1eU3.DoA%K=[Op:KPp2[+0&-#hR&<#HocFiG['r?Ql
/]Ak2qAMa3lD32.gLY84AM`Loh2c1PaR2X]A@sX?=1N6)k>9-"Yu,q9g7%?i>&]A.Gbe18:cS)#
9'eV>9a))#`l=8`Wum)X%NQEX>"hfCjMS[qhQ$IJ':AWK%BC)^?>l%*$V82[>8LTcrHN<o9h
^VTIQ0VS94^hH15icHFKDij5.&Hhg?Wi@[t>N7es1'_1ZR>J#p_CXmeNWW;O?7t-joG=qkLN
6cF"UcH1dcFmIt\/?p^kf2tkUsRb:A6WRQ62B5Y\b_bg,b[l;??qtpaZSDq)t0%sTJIt<bO;
`'LVpO^.PEJc+`UdSi!@;1fG;%PZn^nL)p2XQb+_/ZW(gK&b"rF50NO#tEEHn#N\`MADW;+a
7\)@h68pK"O`9:f\1).3VIFE-e:QfDC@;MY&1p84MO.%s7A92\8cFt]AIHchYIog\&/OR/+<;
g&"$:AW\R8Ht$L^fdKNT=r15O!MR[O3W>CB,V0M@0VjWqZX$A7Jk=8/2ptl(Z:lL8i^kiO_o
hN,:Zsg<_=KW0ClV2oM(BPf(Wi>2>'?[QY:%^fJ$hg#)@:2oW$_?eXf(>,g@&b3jlO?s+c4C
.UuV;!mu,"(R)B;8L3sWYs%-<Y>JTOsSc6hm&O-D5g!>"kR+)o.`07@eQ?H6>MO_kt/dpT9^
Iq0uauttk$9?Pt50EZg88S<RF&nN_Blo1MBK@WCSItDaH8L6jX'mENOF9]A:Z*Ql,9b0Lr4.J
)J*Jn0^91)qGPa0LAb^C2/&;a&gF3=+:77BSG'DNICQ5!?iMoDV1YL]AVbAY&5YY*HCW8fOQr
:_WWafqo^N9ftE^KPi+')j)*8-4P/l-n3R-2\BtF^k]A_@;\7hKMm#0kl>e7!p:%mad3cHiX<
>JH4DFIF_\S^8C=%qU@qt7r#7f,V[5")4'1NZ.S[1rgiImMj3;%>9Md%W/=U*6seHGo=h<Sf
+ZKA8+P=%EeeX>mod]AU\L5M(V`.[m*A$a"OHIuE)QhB>_W4de33l&tCUC6s!8O37%?6C>Dh-
tP:Q%F>o!%8ec8apsg'p_R<Jo82UVf?%)"ofR.bngTVQ$=U?I8(7$<)J8FG9.Q(ucAcj519!
&5*)+\,GM0YZr`.rbUQ',*plBc@m*@_)98-&h_L@ggV0ZNKp$Cg7n(_<Z\rtidVH<NF=4Yan
269itG4(miWD$^DEmEC#S7`:NU[;CSEeLC4Z*W5uFZU^3.HImY*13OC86S;QHs_fZbXbYs'p
FK;?!f=6FV/p5%ufkpI-#n3@:\0j^K2I8pFiI5eWKh,aki1df6BIrPHF]A'Am!?bR0m-[3k\a
9"1m>@Aln0YqDrh:OW>toGZ8&4*gf=^)ZPcupE/,O5AIdc<m.i4o2K<pb@^.>,5sb`=tk3ss
2."u+.F<.Xl%I?5[h@UC`%O%?/k5UhqqW6g%SR`;BKJS`c?nc)uR:sSf@S2^I2-4Y&C\s_lo
Y:"ttUq_9:bJn1o5+]AF8*N08#V-bMZt$13a\L%/s>48s_*Q?<[,-a.XM-FSOT<G_#5qm'QZ<
nhZT(p;gMT/dn#"bJIiLImePHP/.CpJ[J!DkWcX#o6.21rlgH'"T~
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
<BoundsAttr x="0" y="0" width="114" height="72"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="299" y="7" width="114" height="72"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="report30"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
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
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report30"/>
<WidgetID widgetID="06bae1b9-86d5-43d0-8389-21d71a3ea643"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-16636871" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__81564603BBD4F6BE6C196F5CB7615F86">
<IM>
<![CDATA[Uq9QEAPq%_)V_]A;-R\33Fum'S@N-?B7`SQ%=<5"`VdnJmrVa;\p[)!u<inN#bu%u13Td?q5?
*lCOV%j1^qdaIAS!.:rnU*ES\O)jr`t$MPSet&GsoeILh_1rT)6Fj?nFT+1(ckW>MpiO@#=m
&p`0n4>Q2!`NJ<H'N@c;fhq4M\KP/:>TjrC$'rl"\^b:1+2T9,fG4d/'QcId<a@N#5P\`O)f
/5@p\X<VIb'i"5S^%m^L*FZPN07^,7?>h6UA4ce3%lW]A,76/9iUT=8ql(c_b=Z>-P_(Wd#Mu
/0ZZddoI84_HLIGN0*^c#_$E%M$a5OJn;1,`3P3DT7qsTHL68@GkWMWX0d_e!]A)qEFeY>V0I
B-MZtl_iVF$/.L3an)!]AUpjfAn&:@FU-ng,j2LKR(5Dp$j`9;DFg3L-Yf]AmC1&(Y]Al9.HT@;
q8q-/b-pld1<na.R.jW6:,i@o:WTCFV)-h:TpaY87X;AXefW!U,,Zjk-N++Z'grk=]Afn\ST;
W+KUc!6[l_\N2MEA%6B5K.qfUuZP1X+OR0kS_,-$>A]AN>NNGV0%:=dg%l["mEj,r=B;f+E.a
FJ`+r>UQ.a=Y`CGo)*06)9BaB?desWhp`)J@L96<]AT-DQ]A+bRO*s8o+OS4HN`gcJ,+]A2_&9"
?0A"rO*a@N:^9;=(u2E'"`Cp5#`FkUjK-`>s%f1..J#JqX1Puf6c.WNhaSedG"9@.<b@.*Cs
d3b6-N*,)]A7KJtgs+G)R"InSreU3u5EGqDD+h&X/<CI@dc/Ucr9JZTijJS-WjRP'nmOJ\PHP
5kbQAgQ(:k??a*eP!<RhU!)m1T(2Db1+MPF:q`Kdi$KboenFP";mrQBf["=`l7WjgeOK!FA,
e"*oD(\W*:Bb`[?)U@tK5HtBN'ps9&AqGJ?Q@Y\eXl4-qt>8IK5bp6R/Yp=S'Jss:Wkh$`(;
J)Dn$$UnM@0,CNAqK[<#-:d5h&6@"KSJF#kb7jBABaDr'EV=cb;r9W124mU`P//Qr.SbqP+3
8_>IH#($S+kDMnPR\XlkN!Nj7C%5sjPBGF5g@82I9c5mP%,7N!"g#Y-Tj.8^=.>DV%,&gTIg
2KWJ=9YhY3(.Kp'+&"Kobp(]AV0,U;]AFO;o'8imd,e!M)<U:6eLe#KpDJj1Xt#V(<b$h?^(\C
ea1O;B*aQR\^dE3WV@Sg+Dg:_$!M$h'8u[%cHm.]A<F,P4#Zn[3>Ck2f%tA_WFIa%I!Lp@A]Af
".e]AAn<FHC(cBaZ&9`9(':M$Hheme'a1enmH_C#%3?Rn?a2T:h61<&'gq/V?"`#g_<h/6dEL
e2EML*K'6aDD]AK$$Z?q<1P8+M&]ACHBJ[c9KS.9-0F:oU4$FffntQQbU^9d36J6iQPKig#QH$
<)-V7h0p<W+bK:ZtFaCSpuR,T83graB[Paa/n8I$YbM2NE:ea'0n>30;E_`Y/?-rt:C,h87F
.$6T-8WaoQ-?(mF[W^+4GEUAJUfC_@_9CDLq%k$]AdoI5En:!m,.mAP`5OQCFlJni&-f;83_c
ep?N8[+ZN2="/C)%LSe1PUJ6.=$fiaF3W'F2_]ACuDl>^9J%jobmTC[)V?.O.EUj4%$\4Zs9F
GL\K4oCNbA[\sH%^^6Rj0c'Cldhq+%)`K9uTAYa]AqfFp<t>i%g'k\_!c.m#O;GS8#AC.fV0q
,bagoX#O;YY1Ws_DQMhiZ^6Qm#i*"c6pZMU%iOEfNXDCI7Sr[\PFZEN<YkAiC'?]AUsuLU@:;
9)!r#9+%H4"NLcg'q=]Ag9o-.A&c+P^-Z3j[0"e0InK<CS0^D-Sos$JB6/^?m%WGlkpO*PS<]A
A3'&c_)'!aYq&3V)C3.!bXqOgJ.6`;;U@<0(7c?m24)pV`*khI=5Pj**P]Aq[:!ui"[rU"r>!
OO]A'r/f)aI;Mdqt)XI3:j)8fZnD7j@5M%"#TX'%<W&]Aa:&tqh=;f]A%`H[Q[NJomLp$:^9>fC
_4!D]A!KGiK*K5rJeNTlBXnVVrfKu8!@>%#rc3tjU#$5Q!/%C#blOb?f&20Xkafckml'l$BPM
cXkQW.Ud(F`p.8Tc@,g?dkCLH[ui;PomG;LJ^pT0:amY"1ZJhW\-Zh,m3uoU%Y5&0m83_=k8
L0(X>l[<s7&keCF69`ATAaMF[dh7'4JV3jWJ\$!oFHB#?Wnj9`2W8rUGSTT=oGhu3[s-X-7U
oI]A72I5A?G'g$o_Jpf*YPTR>o65b?Xk*8<HM05qC`h'@Qm,T&_TpQ?&!sCBbGZJ\nrb'c6ht
:>_pR`C5)T'BBN?QnM06T\WfgY*KY:=%edF4-2GHshdRXA1)\Yqj/-BZ[["[.prCg=pP2:/K
"L+OB$3*Ta).qQ?QqF?UlYu/GJQK6Ci7_11gr/tcq(;th-S4LE:[jEg#EA)73FD/Vs.^,/XF
.I)6,2hf5bm)OTdr=b_pFI6OpkZ;O%36jnh'i)4?Nd-^>$\A\m8:#%A<2g%3%pT^dT<S\)qY
*=:F;MffKj+Pq&V]A^Ni/G\f3&iUqf9gZMt[(ZWB@SDb/!1JVhH%5!>3L5<_!>Z!BZ60OK"Lu
8VWC(\)lRVV^<=3;>'/dh*1?Gq7\f/I`I<5a"=L^M`N9<e4qBFDKZM.B<<?]A)`9q*8uS:Kfi
do8OSn9LDQf]A8fWHimN-#P:OkGuIGApRK'iCc#$m7gpr\Wr9qH?=&NqKsJa)=D*fO0raS$$$
1Hrh55U3+7!D?$GV]A3_0Y3EG^id)C?H.2q`'8o-"V:D.'tLj]AsJ1(]A(c*#Yu,-N8Z)ZubK-_
b^'p\c[g<f5_^Oh;c6KmPT^09!\c7T?-TjgOEc.pL@1\Zru]AAQ62o5L*aHflnGnon)^p%E)O
VQD32;S(u(9.cUZ4?>+`o+oHNBsWkZ?Mdb"jf0;A=4(;hDH;Jr)A1Bd1;q1937VO-S(J-_BB
IJ7`e@JCTtAJ+\[cf4es%&sq*3I9J*'X+!%%g>DboZh-ahh!#TN6GN7]AHb$@.tc.GHW<Q7!j
;317Zo;%H_QC'4A4UF+muNJ[6/,8FO=rdQ.3$UP#n'&DXNPkgY6Y3hJY>L?[h)Kk+3>:7(=9
*:PM_*r]Ak,B/'(Bl6"bS+Fpa:aMr[^)5\tj8he"XEj0F%1Ag=4%!hu:1os6GJO9/S.?Q-5:T
3&o-f5'2*!7=7!1TpVQHi9CrhaWdP%F[A0p>Y18JZ1(X##"q^2G?80F/&VEj.ZFWr.lY;V2e
ok9hq9GSdSJ`Tgd=M\8-ZD+K+J;/9,feN7\V_+Bk"bkC%,`/pOqU!T(F)H"?Zs&Q+tUp&U`E
L9fLjBDRC]AM7UL2J)O^Dr-A#qFa"J]A6`oV5Dm$k[k$tib[K&FS*bEcLXCaKYc<e#<Snd?aOT
+r18,]AV2gt=#-l<:+nNVh&6M/]AYa$Nta#m0E.`214pNY.YlHI1L5>*,uAUI7o0`I]Aj(Y?m;K
Z.PCK>_VW^r,EtmH)#aI%/UEKmXbAbDnsJ]A":9?Xe\NuJPi>O6KKMC't@D2,hA>[rldDO4oh
3+[170#5n("$86."0*jOGm]A5[3k.]ACaRKa\((G6pWdh.`DZ_9^[0\&/"Btpnp*^s]A@BudTl0
D,K1B$^*CY3l09+"JZ*j8^(gt8#^J@$<3f]A2#N9OtP[uSe7VPab`\!Eb#rdM\2$eIs&?+=KC
X)5kg:L*ZG:-RP\c:gk>Kb802$1e':=7Z6_\:43?1Qgkrg`_/_RFY%!m-uDnj@e'KrLl`[T@
!%ga(]A$5KI]AOM\$)egUqFpD\mn'Xf".,J,7n'(-O3&XbVTEBj<f.]AN@1f=\9W!WpASlj-c=!
G(5&9V9A0Y!^b9qCUSXVGZQZXPf6=a.)idiFGKrP[<o<M(%E^t,/:aYLp.((cAfY7.9-?%+M
><6j?K`)QN(B-r$mi<jJfHIh.O0tHr3EJi._WY"`.-57>ZK=GpWi`1op2pW64sic#^]A2BWZA
'GbpmLYZ9CC:hjD&Z"tIT9Bc\q+qX7kg>FdRQHqF(faXr11N+SBBg00&MpF]Aa$T.b$#F/_*Z
5$0p#(tRTR4M?'9emf4%:l^MO20m<j]Ap2s5(hY]ASW9i;<TfGP_s2"/2IqccB>SAL`Y+9UB']A
NXqUlHXC!la:r#[\c#c!GI^[/+Uj't77OC4RbP=ofCYfkB[)B"EQ"V&/6ta,(j>O4DE)mCi9
#Z+)1nSQY?:h7RjTA5^1=3Nf``3W?_&)G(+/,%tRtYn3n$?IPRT"=q9d(o+QEa*TOIX=S5e%
XYDHd')SS6J?-1eL3GAShs0]A5rCEl1Vki\2`En0K6Z&#Hn##7l70b#YOr7k[ESI41AjW`qDg
?q]AIYsmo!=[gpBmbNnmD)_X.,3(&\f*Im;^bEBA0DSi,AE))UYVc@Y,dj`9nk;,i(0$`;kpE
i.s-G+:mipV8)g/*tLh-*,@--=XT!tKWbk=O,H:6DdU0.Dk:<2A;+A`+(*2dGO9rW0=PTJ1c
^WQa5&XCTl[F:a:X(g[VS"<mD7&>eOQfUO$(J@DT`jS4.l>Y6/&MT:H_A*%8T_LT;6pChjuK
*4oXTm9SFA.E+*ts=k9dVf!j=mpb/MH1SjHHA(1I$Qo]A:nhl"E:G,IbY4!<T\D6GWtE4>^0%
1ode+3G\0\/Qm14o,L2,uq>eE=/#TRZ%B2?DL"BVI]A/gaeB5.UTpK?qcF2Sg-/!9i2Uj;/RM
0s`p':]AcbQuPVBo:BZ<,'qL*\.CB4Tjo/KneGc0Vn3:"(#jj<m#i%n1q'I,);_q!rEN5AZm;
X\[_KG$D\^>?4qTXTdBMQb?F*:fk3/8#MgG*\jsJ,qio%FgiS9WIM[f0Uu9S%VKJ)PKS'q@p
IB$m$rph<eXiQ0C?"biJce40W_3[I0o03)0'MA^-F:H>T@\3S+*Oa;$/oN$M6:=0lL>Q3bs=
-`cI4$-\_!(>qrZU*kR@Dg8=aN::Y-JlX3^[)F#BTX!@<\bq28BQ(d@mn4N9T?I*J0qCp#X5
n<Y/NG@Gt(dC71R]AT3D"#g]A=Q>GA$$rDkR*;Aim:U09pm-6MO<6QECh^6hE``';DFMXoq"1D
QiWI9NfpZ\*TF_3WU-e+YZ)%O]A&h'^\&o7I7XG-n1gm?m^>6%>XESQ_`+X*EE$&1[#^!2h(P
6#CjS0+q=Kd1,QWh5R+e+fL%5'oViKf0ZCrPsR6FP`E82REnohgj@l*Ik5Pnb9e@U_oVK!'9
jhD$8Ic6\FuoTcb)[f0sofl#i`^WQ!9S.*Db-&mauq(gB\QrVCY+R"N.?KgEGKG'D0/bC3ts
B=o,3^rU0KBiHY&bfB%C7*BWO@h@:[WIPE>lpQFU'M7K]AWM!;dAXj(d.N`Z!NHu#n:h3cKUe
]Agr!/>l)&JML5_JLsm.@f$<MECJ?@!J]A'PB;Hk0h,X?5clEHDd;E+6N*@55n7ggiWn$13\jd
D;SX%UY[V'2l@2C`2N9q#4+>KA9%Z$H,1f%0"RU)g-S[GJW_^E'u]A8oL5+U\C_]A]A3*P'8TBb
,(/+kaAGu3/)ba:SRc1YNLj]AcV=k_W:!pa`mR:NB<a$'q52?*8H9c_EFX[/)IQJ4$/$7Rqc`
br@Qqkfe[``Br'S7CS+BL7rc,i)>)r"f\W7F0KLTH'>"6ij.9_u=89iOR7fUXDZN$plR(5*)
^:bT:LeXQ[PTM\G>g:95MDpV]A'B>p=?;o^AWbN<=_(:Z^:j37A2%)(5\aG!5;VAAq-9DN^gg
(*\!pV*QL1"H&2!k*R[0BDXL-uMY41m60Zi!8YGNK^.Ui[Q@eV)IOn!%/):]Aj+a7Y#*R6_3o
0ocn6tl8_)?0))_Di(ndMYf`g\PGaMUo"&/V&43;G5$E2\m`H]A\1e.8_2/kGDp_)H?FB'[mV
/8$!?H0U7hBF0#Fp6be'QmS!f8G1nel_,(`=e_;4i!o8W]AR$T/-WQ`np*f"4!Bshb-KlV^X_
(Q,^R]A9Z$]A"$VcuHFiT?jJ\.Fg$cUuo7E#6%ahiODPL!FMDB4=?O[ULuG@f]AE;hqM.#2Lh1k
XAMNrY:s)$tR)"U3#iR",[-%a."&%2A3o!13aRKHYp?<JO&p=NnNonZ9D\qH+9L[O_!`MuaW
<bl[&>9D7C.rd@@M!$l;*NfK['>La^>iC80&m%=7J3>\6rIIb,>:eXYJ19fE[]AA_741p(!6O
E:fu,]Aa7'D'F"aW,!GEl_oD^1E,]A0r1(+6Wdp["C?+As-$ao'*oOJsi]A26gLeZfLt4Sj^CR!
P"53ebSAWg(8!c;S^E=e34e#N8Q-fqQ>ioW*,SMbm1;QBR4sYjkV4*bZcS790O^HXZ-k;^rp
?l%C+AbZD9(^f`+T;g2E[CDPkf?[jS'oSON,.b:M%B0i9HSVNijQ\R:+Y`.gB11;"VSBM+&i
b%5=nd%R+G]A(!-[qZ6`!aR'>TQ9dYHm-LM@_L2eQ9LXO1EU[+*W@d>mo\mC$.(:$G`MD=\dR
<7%2)Vd5\8ES2++/01Yg;PCGQ_R(uSoo@p)fDftlsDhEU>rs1G<B$5dqbL@p@=htZCdhf+&k
pE+`[Z"Z1hZ;DUB>3%Oh>5(82#b.!r*o@UcGTG8<ZYAbAW,29\>RX7/dW[k4j,)t7(,.s!\N
-CKdZUW696Ed[:URK[j]A7J#/+UrRsRoQ!-"-VMO7%.$XEm#FOrYNG-##bD#l!=tS/PteEk7u
WW<Q)U^nh]AZC);W4B]A,\?DbpNkL8'<*X(qbn[I'o,ACR%GBPs)RYKLG4iOV1rU[S@Bf9M"Hm
NK8ES1!/oLIJThtLA#q^D7`'ao,Z-4>aiicOkUm1o35\'K1U[Ou6X(G,HE-I,lMn)kJVp@$7
b%B3L>0[YjPd%7GMZ=c"9QPe_s%N31%/Bg8KJ9?D@aZX&9i2Fci2$'BH9=Q*S)3oY,Tj,dPi
Rmi7fgr>?IZV$(CDK_oXJh,T0Ete%n[EfKWp&)\WleZR9%CWk,F&pG;"^;FWq,m0q=0s4h#a
7gJF3$/3T]An+[N8;[J>^;frOi(fQEjga:CI)"k,fc)7tZ>'DS^9&p-/Y'lO"/cUg4JqEEAgg
b?\N$&-I;A,_'Z64=#iA$.li?H)a%b.64c122c-;kmA#JhJNp>YcLU@X@Q+AI9V<Jr!Y6J+B
INuEr`<_3CV:Y6\DAUOBaHjj_/M:@q"M:B@g@7Tt?i5c5P/6(XE^qeY+@Y")I4$45Mpn-b'%
G1ab&GS`U?1f/??@bPJ]ALGYrncfZ88)frJ:`qLj0P:hnB&(DT@))YVl!*d!pI%*&EDnn"%*4
UTA0br%rl)plh_n4WePj9G3nH-:S:14"0IqFPYYr#=Oel<8P['(Wp*Kh7VH]AJCIm1^h?=lCd
qj$DY98j+aE28G9#o(!LD_m-;O<lVPqG/dtn'n!KlVb-53`;75PfJ1S=NL-SI7:p.H!UZb)4
M</a`Y+UOcaY)o@#RRpc*"f:3QSBSF9O%kNGuq.LX5;J6\*%8&$jr)AaDcGr,d6)\$r2Dt2?
ABi3F^[g0Z8/F+'=1sr)0JA+K]A:4Irf$;^,+$epP0Q1G1:![.fm4GD;Qpjr+M=.D_;bWUKmS
K<Hqmk6?3St^m,n6h;QlDZLG&u`^kHGjY/UcgR%2D0"a9oKl`]AbHWi;BD.5(A\u'>lHIG89)
r&,MOM9Kj<dR6&7&0HCQ):ReSe5&f:MgF/Al/+4jKf:VO,YjGYF^U"GBUBp&5Ilk]AKkJLmUg
LR'b*q?+ru&_\uPWE.:id.N5&o^t9R3+4BM&)IHPOG=TlDrF3\c^G9p%ECUM`Y.'8#h\a@Li
T?kLI[FR5^KX'IIQ!smL[>'?$q(3$UB,>a@MYs9gU"Xbu:=)n9F1E,e3'SPVZb`>"#B^nNdX
i74JkZU)9H("^A(^CeN,I"BrQ#(WJ/*6eL%rZ=RPKUE^h]Al<iEtip'aqG+a/$O33iYhcZX]AH
hgaGEi4k#X^D'**gVX+$">0jpg0&i>;FRijBjJ,(.J2K-89,nEl"$5J(bIpn3(.E;u6[#C%-
,VKTNp:<Sf[1[@siL&b46l=gg?$^:>o.*/E\cNYM,/(1'_!W_qkEW_r#qF&M6ihGS21Kt'm8
n!1;s-\.-jJrVbE<b@M51UY>"nC;2IYeNO5f`Cldfd/@b]AY3M"?13AFTUFaUTWhCd;&ReF&=
K1Od_WuI$pGM$ofj;XIm%S!?UD?VJNp)=\rm7.$E)]A(H,Do##*Jg]A*OcBkN,-3<aq3gY:^bp
XLC,g7E7[JS7!;'EOj=CE'Gfae*(6k9?QQL/,Mmr1/(K-QIW;P4n1i1glnB[>J<[7qJR=UY9
loBDk93QQ4^pspcSD61DJ6i,rCN)TL/_dcjo[32p8Ur<*s6*ts!s?)(K=$L2jsLBGD!s:24N
"/i\sC5/+6b2\jKAaK6ee.=oFhtq821`K%lc:["V4cmcr'8?k;/Ta<Z(dPMM8taSrXEPH=uT
:O0[@UYqAb=h]Au^TOo(gPbLC>W/]AN4lV/#aJY2;6.^dWsQ<XZ:RLBH/7gAI+,bgf!Hbk>mV?
+-ORd,IJPjAEH#EoKQ?CD*Z?:NETSf;4AZie;Lmd<1drX/qT`=S2.,ULuu0)6ZMCI$gLH3_"
mIMOPbR;NQ8I<QK3_#SJJ>0>tWO_1F;nM.O@,d/lR:t>LcaY=Zhl<&:W8am.T>>DK$U"DC,T
0%Xs$bOE#6DQqfZD5]AeEi`#YEi_cTE3';q3u5E@0C.'l[u[LWK8la#IF;GXP`(Y3cVM4/LU=
k16EN4$a/V-R`d4<QC_`IlAKsWjW8'9,OdurUOG2ks2am\oOfltfpUBPc-jar@e"&ZeP/mA(
m,5`)VN.B#;gc1)-4"u]A1m.r:$HGErahi;hTq??pO\%&mbG7/6b%*NJ99dD&!&R6j;cee"dh
bW8c`nCJpX<l<Dp^%q:Nq]A?:KOU@DjBXip")j<D7(mqD3^$=DmcX*:ET8*L)SU>WqTAr]At-6
l;;n0&m:1q!e<cU@X[1+"#e-iE6gg&kdqh:cq-hj*a3D3dL0tM\>Yio(\UqWOR(`4MZpo9J[
#YMGK>j.I8dn^YC'6F>d+iZLB6uD`*+u,7X'PVHAnCR+>=\U&#nuB1$"ndoK_9((5>#^nfM@
XbBb,@u4-8]Ain)7AHmL<.Zi;r.iEqs/"Sj1-`PWQanPmLKidnkD^r7%qn.@Wia?`e8M!nR/q
K_+fE_K48NP8BO^m,g$)Gu'#1qTr_Lo19b5b%!IfLWFTTGquFrBRVE#"k)\<;6ttG*&0h2CH
,sA^e5Vdal/cMp&tHc8i6g]AW`97h30a`78jil<92l,8]ACAiK9J3\c9FeGN9b)PAH`FtTmb%'
@7-D+AU$n329@4aJ%/WNocqu;1B*:fb8QIN4>CB*%rMX+ajZuq"UCCIRrM)m[Fd*;(:G0Qb!
h]A1K0D^isb"6oAr__$\]Ala,+5/,t3a>3F=^5u`5Ka2jO$c^=qO8NX:jZB@<WD>4>jTapmTT>
SXn"9+)1`=t:=qU0[ak:+YXH<6^^^\#%ii7.2h_Ra#[-J744$jJ'eL-e*APG$E9H(,0PSO!u
H^2b[_#@<sn6ujq2ViG\]A^Ghn4*DtYhK8Ld_B]AVX_4eQT_E(@MnfbO@`iX6'NN^H7p\RQg`L
nd_L6KA:WR]Ak!^+uqB(&p"<#E,AjbC9$n?CN0'&tpZZ?5]A?WFFu*EjiT5m2LBj?]AHn=b,fV'
f@A5!,@A7f#Y^JOLaqD>"?p<=jG7IWUT935,;Abo?q8qN*\e?@P>Nk6&Gj-p=@SmE:PFY.Jh
49TZBYt^'0>od1n7sH2P25.']AXEa4\%*LEU\9%2^'Lj^@))PXpA6?^7>$cP6EB<4qX.sf'..
a"D,4F(2b;rr7-DV+hd?XWdiuuX+pG*RX79o'9)mQg@'lBa5$m-HNnsYl)ZNlWZJf4+>gHZ7
7ndjOpSSWP2d+G[LAi7Y#Fh#c&%Mi;jTN;N$JIk'D;=l_a8l.gZYt$iVpfV!T#nt#]A]AChsE@
)7bZu+JhQ<l)0%*cdSgbd5tFm'NdS.c_MN`0>]AjK*HTs4/*uijisJ)'_`S)(d4AkfkJ<kUe/
j6Dkq1V`^u<-f&MgF[3et7lF0ih-jNSfWf7M,3`"2^@bC0Yep1uh3ItYQs`!`*ah0M\KT1R;
^BAe&eZ]A+oG:mcK56S3>pM?fM'9:MO=LlJB=k\bpIj$b5(@fOc3t8rcdj$T>-WciVBM#c8uC
kKH?XbjVO#EO-n>W3HZVAuX$5?em>Dr*2$cu!f6fu,KF"PuFsYI`e2+tZ(>rZ?$eOF6o[M@O
I0U(J:BG<*-Q?G&"B'l!7%`Ig,M>5Zc$D_J@BYVDB<[G9bE)B*\B]A^0.ZFlb!NA<!+Z2rl>V
u(V\J8@eB\l>.,,V:!]ATHQ(Q\RQnVjd="CR.07IhLfFo\h#ba=XKuC1Pg;CYiZ?7iE%'C!9q
Mr9Tofir31rrT<DL@hfE_+%5p#hs&?3S`sMd;aZ/Wqc2&_N$+DRY`PGDr_\?aB*pTndFd:lQ
,!Li8I>rkJGOX<(l\YbYh]A!^4FRO*WYeEDk9`!:2K9XVoEa;Y_@'UJ.!Qh-5afau3O'U%D:*
:^W$FDim^]A7;ilp<bk?Q>A>NBU=2tq=.)gWB-5GKioH"j>tjV2]A\?WVM-#DOmgp-Oik?faUp
jjuF^_';LF@:V(*fef^[q"ep8Pd0,^l8+NtYBio"*$I?H/J[!?/JX^ibnZ[MXVBJlTh"<=:*
'(Nf*3]A"S2M9'",#VJ_0j%[K;ra1-?YW[o,'>@l:A`BA<h\1\K7*?gb)2Baf/7)TI6a1&.l;
5;GrM-B@D7uf_t62r;2m!^/89$Fa8s0>tK`-cg,DDd=QU7%)'$hJT<99M*`H#R6kDS\O('`%
&AuANc,_u=r3-"Ddj)JW1(%uC(&B@%$+dk`$G?+<VW1Id3H-LWWXGi6+rtDUDili[(3N"/^?
H0"uF<B3BlD;?#%XlB\f\?G?Y.HZr#=6WaHhkUuA!ROhS\U<>PWer$4OH!lm(!MR0[Z1R73N
F_^-#\u1`%FbdiA:kt5,j&`I#("9St9!I?i(O5fY2%eiB\f*C@A3XN\r\BTl&A6aF7ddD-Y:
[]AQ?hl06=f1IoRAPeY=m>uo'E*P\dXY(!\gdlfc>:R'E$VZ*T+t^DoD7"EdHL8UD-=JpkJg&
IVac^<YB$DQI4F!4E=lr8=ko\>/aoN`>Kb:riCZ:pM:THj70:HBqimPU'#4)nnrRf0[^P=1g
)ER3ZrN79k\?jl\KF=beMdUeq2EsUK>q\)23!qU)7$^qBQcRD!+U5,`4H$-S`9[=5>:L]A4^M
=o(`EjU&D4kXYr_7JG7ioQm*#Pj;AE>u2HOScoh(r:M]AnrB[?Yhj[!C3G4ae`idTs7EO\(Tg
g?dX#eEqm+pl#[.i-nc1Nru<L"SX@f/\Z.2Fg?Xm7+%/):k4RLa0`fIO%)c8N3*tAmo4'1$I
K_NWqE4r^Q65LP.UA.2'At$\O,b?Y*,Cgj<5U`n6Hj_LbCSmFF,ot`jB6;dW@[>@4s3fn[3P
h7;Zl2S!7J+RqKWm6m(4ZYd%Kb>l'4.Hm`jODl;1EVQSBLs7,\YF!T+6MUI#0o4m72pU4,Xo
*N\N-TA0;/Mp%7CHSk%4>o%)keshjqP#`CMP<_e14Iu;%eT/$$EB`UQdM:Z#iY.(QP8n8MIS
Zt.t@&aR[":1N(BA6MaPL)c%+-%62=,I2?]A%Qg3c1LP)A6^->&iSK=*j!e3Yg]AE=u9>kWr9H
=n6A$[1TCR]ATkK5P@^\fTB#VMO;EM.^L11O*6^E=L<kB#!Q9/kc.ZDE"VMV?>Pu+9\[R%X/3
oh)rC?012N*YSoQ$]AWg.Vc&gIuZ<gU,Kl$Jj7N:Z1#W(V2i*\]A^pn5im\ZdM%tsM&o[lNl*[
ejn,h%RXhtI)a+%la'Pg)@$S:ePk3]AW`5;&Ffh@]AJ]AdN<5_MXg2=1f+rll&-,gVMl"5C>WHp
3?:kK[NO%n(c]AQ@&qpn?^1?tGgo(43)btQFQsR2q%st0QW>T'[spij/oXZkO5M0o9$u%5bMU
XdPP``*7`3#T*4g<U2=g?TP',YS?=ph<9nb&mKG'V#<jh!5lP"Q60mQ\OmJ'NXJcDYWQ=09K
1ka?bgJA7s\eJU_L\HT!E\LdU`QIsr5afkhm6q'3/AdA$*YI`b8FW#&eHF9F]AP)MrKPc<(-U
JhDPVOPK*bcmcLOFcg>Ma/k`KG_"fa\^HZW%5<#^L8kpm/2`;m7JV"o=bppVpK-lm-Bgq%V+
KnuN&84fW#lllNjaCk94BF]AQR,']AoXLI%3'&_]AQftDcP@Z;SJJMl.NfkoJ;@#VU*Rfph#!sJ
E`R@<%[O3rEC\L;uMbl+#*4#%aV>_Mip$DnApj^P1se8Idr5IATX:-0uVFlO`@AM9[()W,uQ
YO:eWJ'[;.qRj.cu*BRDM.I'WM/;DN("eboK,+(MH)j0-n1O%?NtgsL%75-r_tXAnhS%8K_G
>VZYJ$LP(Z%DE8;;jT_'\CO.gr9;im+2R?jnG\s4<ph>T1`9-ET+G.K#UT3;i#ruSl&eF1$f
dAdm3Nsj!P!ruK']A0DfjZB/,(UDIcqV)#"<qk!c!0eI)?5AK_`&DF8FXQD<QoGQ?f5`)IEpi
.Frp81Y049e]A8<%C\;?cm\;,2\Pe"^&kG!(Z8l>&d<g`R0W?*A<&-al8d^1tF^g-B2=LXY-q
PSgs@'k4%BISF:$b"E;fk?jJ.rN-e)M*7.K'eN&.pDB4#s:nt#&(I#O\"@Cf-k9DmS%Aj7LL
ojhq"R[HP',b":u?1W@)\L3`$.Y9p.YODo*QS.(Y/Wr5?riV8/G.f?g@dPID4X`uSq&NZ$I@
*s=3>M'FWjKHfWukF\DM$E55d_>]A(CKmi5?CIgh=)(Fb+)r*Jj"*AfUD(sM"YY^1U*r%E&A8
73!s2nhr"6sk&7-'.&MY)@i0Ig1,is`oQ<K$h]A:2kTqde5j=)63ff"^fcOlfDu3FUebG@V7s
<(2oE]A]A<6HgNP+lYD0pQ[[m$/MVM:".'G]AD&,n\u@ap%-1qeQB*1@YP51A-?)#AU$qMECeYA
<L/P>E,V#n+\ErjKA$"`1"D9>X+LUg&F$gZ;1bR.5'%hkrE)L7Bf?Se=25PF9n-Ta7.eScrU
8)s%qGS?AGrL-NQnAg3H,"I-C#!</U/8""aBc_;_:._6,l8EL<tj=-6>\SqhZ',KPI:n95I0
%$f+`m;/^e#3'iTPit\[n&TpcDK5JGV(LLpJ<Hh-e`u9\'WVj\gXhO5AJU.Ye^$+hj@iK_R)
V`SKiT&3eIC0(If"-_5PB+EL_25_&4%oYrM+5d?u0,m(hA;o$I-pu%KDHF68i?lM11tj,p'"
Yee9fcF^ZPE++I/fm7!32qa1n4q]APmrGd0ThmoG,Dh]AlM+no3adJ%?Lk07Wc+5d*c3rnIn;h
9PU1K%GFs)!B&(YMupmYF5[p)KU7mZ%S63XnIK5C=%H3lPn,9fQBbaS,Ni7L_di96:DuMD_:
huRDhqBK.3$R$'1_/F.L8o\h1$VZ%^^'l#OC8!Bs0<Cal:J>nN586cp88VCSN#N@V(X+sZuS
PKE*RjbQmDkZ$JEbf+/0oPL0sbpgC+BT!+oSH$oJ`2VMf2iVk6!pqO/s1^;4Dr*_G4I8$Wl7
>;%JSQ1%,-[d!NORlS)=qh_.[&GrK):fl9[WbH&Q^B=7@c?^l1YU-HY//YZlP*9Na%[f$#)A
PHn8VTD*c_drZ:i:\*XKe#;E/A1\38<Xm1#rb[+r=nB_iF9bKUG#3)a@/W^3/T4#4QTD]A+#!
\(E:5is2rr36!DGtK]A>Z3AqG?d$4[.c!G(L?8L)d632ZUGI1Vb%_7P/e9Q`Xd[\-9JOE5#1r
$j-+;$OlI9]AsSK>-=Q8!^i1[YE&)PPuZs.h)?ru.G\@[&quJ-u;9G'nB/Z2tn:KnX*kW9*eO
4/,SXWtJ5-M@'VVrM4cJ4)?bK:g_`PBGPTm:r*%8G=,!?DpoI&=_[lb-&!VmaE)1KRp'jYq4
2U4qMqMV_+(3/f:@`VN5gR+2bnm6R5^7B)CdUYWIeTB1?KI*[%_q9M&Z]AHJ5[:;P(KjU[7*r
C*B//lLLnLmK\B8XY5Wi'H?^O.G]AU'3)p8+gah=\;k482k7G]AVVFa"38WX$M"R*R%B^Qn(K2
BhZbD^lRVX-@(glZ(:AW:@'Pfk$-nFJ`&X3q*nlbXP^X[oAqKFFMEg,%%`(QQOP4hnj#XS^D
,_H?W#/R6W1n+,ic8*#H=^&C:*-85/TM4sk<J.Zb1/P=Vu#;\\r%mGC>E,)H0Job-LUWO.K`
@>nqpam420Y]AOWQ+#<PIJW'PQD58rr$qDD0A(7#X:)lRJf,/CNl5K2OjXaZ09#G#iY+0B3"\
2D=aP1K,Qs-g%2Uo:0^S.dEeH&/Nhk>@QV:Pc+*;&:h!t/:Ik+<Nr!X%Tk;E7<cUt(*qHpC`
R%[HR=9[QM.V$P5&)Je1N)WJ<1S"ZDPPSc.0>dlUQo9f!.E@<?Rfi4MsjHnY$P5P)m<BL`)C
(7.">J(!oCS8oK]Annu=iqR>q`UcY`Vs&_m0SGiX-cBG2(_+!SWn1(;Hh'+jaRUm1i%[0'qGA
oN%LZ(!id`;`[dd!80%Hd@XcG<)ci.(>@-B!ZVSE]A*GNk_pN[s2*NhNm#,0h0;W5TNVR,X&T
&nUBOr^%6mFYF:WTuA@#BZZjt28=CMTpBg=%%%1:aD3d!f8'?r7N`$Ar:/u5AU8u4"=VAFee
j2r&.*M3(jqjW)YS5Inm'%E424C1I.%_YRj<#DW)d<tJAK,t;Bg5S+CKt;VesDnZpFmO#?.k
I'`"`O7FMm\[&n0%qN\i4_"60/=M]A.e[?f?r=R#8l[X2i2:\Xc2*5!Q4c"([+YQ,$O2N3?ck
_,%Q`$(X@I(]Af20&9^E`M'hqc\Jr4ZAo*OUm/2DpSuVciXnr2b57gh[?:=81g)IUn"<F&KO9
AAdUnk$KpOZGUaM`kB;=DO'E/ms/cU/\c%cr,.i#/@d0d/e4=RArP\*Kk2F6A:"KTr.rD1uh
$,.ueSc2E!Q1XOco+W[<=(p]Af&1+OcGa#0VFrId!,s#n0G71reJn4=EW_Zb!A_OI6m+jW63G
0o5=5TTjp/!GU2ERqd1%N,V'V'E(9`G`#-beSj-XpLf_TrQ:IJWB%Ptau2bEOeY(S_Y>nD%h
bX:GO)#tY@s.7%9N8mo*#Y9>kn[##G31XH$,en\^/TJLbV^>_9$I%WrmFjAE5C0r)nm=1H6!
bqoM(WEUVk<a.';_KV0AQUHW*P0g`(:`)pTo>`]Aa;Rr9U[7i6(DJnnn$5B%C5>1s&q%J+&+J
:U?[b/r:TW",fpnnVaSi-!p6PEX0<0o!YZ\n_K@R>4\L<_0E^LI1!&<GqnoD3lfcbjib+?3(
-Hm^Q&D,iPXXMX&`&*>]AYk\5aIVXpfG;D6$6M138dV2*>L6fuULLP$#_[L$NOmg%2cC>Vt[u
/4scYH?d[Lj]A'Eg4c=]A"))$Q-GE93YrXk=S!7PFpR1AdjplUoro3MTjGWWLuFKE;s/^;(]AWS
<gC9B[s0I"Tj-IgaO+JL]AJF\n/d$#G*>:qL:&hNOm?`Y\g!T@UW>7bXhL7]AA9\d(j1`ut&nY
@i2?@uNU!1^"hDTrA,,='TTX-9\+Bd"b5;G+:\3:e?!L8j9FrN&L+>[1>atYO99ULT7383Eq
P*E[E:acZJEgZp+1!>aDi1b`iiVeq!$0eH&0mktB+aiGIl"WLiOlpV2-^BtMeLfa<=^Zo58d
K9c%ukC&2Wf!3X1Yi=+n!s+3O!`:mXI=X%XVfsMfNiL9rO!I?URpUdEZh.jZ50?f6!sP#G*C
AIJ$&`P2/Zf1[aOepbkcE$4\CZNV&r;KR=Ck1l[rgU"N[<XL.9T:pm;;rt7g4AUHXT5qepRs
7oO"+;Ft;MrQodRPo[,k)CN<W3AGNZT)U35SA!"$a*)2U<<DM@qDaP*,O'f)gH"j0h:RWFDN
YRa!ms2$Q%X$Go/+eVjDc:K*6QsPR$b>*L$UQ$1>jhbOL]AT7YX2BTRF.sF1k5nQbcHiaqhXa
h/5Kf>UZ`'kfZO;G%fo0Q;(?'U!UBgs?Q0Y`Zr7H2&/d_%N>+mVI\!EP=7X?-Z\-lX8(ET/.
H-N.;e9+;mdL"CXe4CX3Gsp6lj(>^#3NLXQs"SuW)68I<jZdI;YV[&("K3\aVt]ABB3U?\d5=
f*Q^cg^5m:A$VGa4G),cZn\n)OB/c?<3;+l]A4-/kYAs!(:5MF61gSZPT[e9I5npLF`#2!:4]A
Ph7.kH1oB9@[4:InodU(L05J;*7->8=R4eX$i=uWbAU]Ar0Ip3`S'A[1VY?L4c6`cPh%#(R3@
9D=,Td8Q;.qq>!$8rPpk.Zk7&Xn*idh3P:]AAfTn9-6c756@-B(]A<93\c(oRqr[Mg_'h-_W&P
VWk>:q\4,#D9)72F]A[.<9-:Y(X-S/'QR0\onN0Hd5oX9_OWYX[PIG:DH<!!ECTQ&M*M.D@f"
iRW/eg)^5?c:/?sZL'c8#-EH\TWhZU8+Md14/fe#Y?M"a]AfJCU1n$-gl,l!D-Y+#q$p=6WLW
q`aL$cWqMIpF&Z0GUE-Km&MH5B6ekHKBT2Q^E[Ue11@?W3O:l3i@fir_A!NtdM]AD'rKh1/ot
+[`L*4$WWu7@n+Eh!;!/**1oW1es!ld-O!JBT\bl4K8=pS@J0G%pu^GSo796_"WrdJ(*#(QC
L1&X+oLZsVW+5a5'<@@d[QWj-`O<P=*[Ci3>\$J[Iq=Md>TOM(H%ZJ?;.P5C@6'UHliD,,33
ieC\SZp:^)Ha>Z?lU?;t#uK96&9phs%l,Cq%Z97BIE3r:VZWp[J_L+7g#rWKh1"A9o!I>U:*
=Z64a%&`p"<5HR@3>u@%PWL9-DKG?.le8fAgX,.^H27-^*l`Eona-2KiGFiklglsjon!Q\ON
&nh,^*4t_^B+YqP"pSq<H;_\^ESV!;K`U0"urS1+,!G$VpmSRS5"Ke0o\9W[R*,G1P<H^\`h
[/+sZd7M@S5+#L+Zq4E&PeG8GVi6LiTel9P_e(TYr^D.FTcSEXP3lJL!UQFF]A@ZJGG$3UVMh
]A.#ans<^OgXU09"9TuoEW7>A!0VFiqA#,CI]A5q=$K?u5;1oY7p-g3S(B1Rk!iVTn_RPX1hg-
;gGUJ(5EC0WkE'2+h5AG3rrAtDTOD*]AmkN/2XOHVs&S$,lJE.5Wq(#_5=/jF?VVee\MP+B]AV
g'9OpX/WdLLMLi)g_T,UH[c>Ueq45@q1`I69^eaX6#utIN$ba[f32V>U/">dkro/C>u(L%KU
?UY\]AcXq?[T0cAXu012h#);WbYFRG1bNO"gCGt#gsMd,3.dZpq,2lfTTV0aka!?,j<X)8lWM
b8fb%Z2ZZVu?IoHO$1FBd.#id-bhKbiRPo>2#n,Hs)&9Z)Uok)s"5i&WHIfm,OcG"!=_4EF$
B83X'*k[6pLGk7Rd:'3$%OG5Z%H]AkN`K(u)\mqSmqJtBUo4_G\23`2GareTX)#QLG&:#;C[]A
3o8e1nTZ&9I?0a9hcH2`rd.'p(&EZEc-&I!VZhgtqXhFmbYa8PP-L'*AIg*h!?KcbB`EV^(,
V[2]A`Wl8jCWo&m$mVB2!&D$Ca3eIu6iV026bM^Y#!ab<%G80YSF2%R$f%L`7Vq*gP![@80pg
?&!;(-DJQ0(#G7usZH$9E`*YbTWChQShgcWF_#iV;uMB2?$F(tA7GS='C)hY,[:$8TSK!<%@
3mS)/T^^&Ya?N6XVB)VIcHcK+%"b(*53O@6n=eE^?WV`M"G-4i<MB86UN-N%=)@&4]AikM;Kc
!&Oq@?mFiS1cI^W3U[nc2e$*85VGgCkj9dh/DfV!^g>k$dbeJm\0QV$mobmWCm3oTsM*ERFV
4Rgp+DrS%f/=m*7`4n#'Hu:CJ'fc$dM*)E-G>''2XJU\4K9p]A!MhMBn?mTqHheE8,SRAM*,1
$]ADS`(UX`k^UZ@5nY<t;NR``q[V=)^S2ASZdFT6)GaKA![SkJim2C%GRMsNC5_2Y6?paenMk
d_-GHWf05,1:3Y6I!NYtYgK5Fck&WNc**e/C"4Oa@Oig/>(+q5*H1fCMW15*sULd.@BbGL*1
7+aF+o/`%h8jGKF:)r@tGf:s=A)d`/=g5+R;3nX.P"(\\!%HAo:'oQ+uF"n@]AA]A1e%agma:*
@ErmPS6DR^HuauD03fVK\h2/$1L0;X9;#n!]ADK><#,N\l\Yk'cBZ&<LeO815\u-(_QItK?Z+
\f_TSdiVK@!;jZ+e1kc/m6:FKc%a!nAXo>&;C5dXg+M)5O_a\M@oifOhY/rG#"08X[Ig?u,4
WL]AW1qrHkOW/jH:s5qmd43a[LF)9m(Z`>5Y6rK"jl.PAD0'KkLS=Er>VG(o[Gg0kpl7PH.ot
tq474N2,)BB/,NqW)t&GO[G^QGVrm9;t:lMo[P6J,DP@VO_&nN``A7"+54B$^ds+#7HG,(DM
gA2(^N_TGBpXo7b21q=ae4KciKA17f^!Q<X,q9?W@n/JT!!^m,Zj[qLAgqPW51B;D[0gnnjL
gmcPnB#@6JOJbJaMQD\3Y9Ra2l:%nVMIAqRbciub9-9-[:dudL^=0U-uI4)^iV*e6D#8(]Ar@
rqS$cRNK3J<(8"S(MlqX?L%B1!b_:lDD;n*q&ABT\Kf;O;0DA'-P,T;>CB8ZbP_P&^>bE$o)
+W/7\oP30Qh"<nLE>*Tdh:L9FH$q28T07*;B#K[O5)AI_S%U,.V^?^!MCUg_HR#k.,$Ws1B4
\\M.LG53Go9haOrZRZ!Ik-AN4?ot9Rp=(I)9@Z:.I2b4<T#=/=q6WDArF%0m$B8T*gA\OIML
M!%oQ6!b1i!PUP9JJ(*8\p"*TX0U!p0%Us?n)9Kq]A!B$jI:!hL[a\iUlgeer\,.$mlfqVrI)
KPe`WdL`9b(W!:ndYo/dpF&8@*`l*gK!-u4QH:U(IW=K?E5;+J3J/U:XsT[]AX4m4EcT8H]A8u
4Y_k#pW_.MLJ"i!h.Fsi:9BFB.TcLta1YMo\W$/<4$]ACeC_FR$1)^pF3DYSHn,b_0,BZ>\9/
.enu4)O,>gCFGORcXP^#Gl6WY&P@bQfnHiuWb;6B@o@>sRQ?ei-Ai9D;XM$So=oT,,TIc.lC
2EM\&/.e#)TKb:I5#9!L^C@1kfSji2B(oNE1cjqX,>6#3OcH$k9!SfE=>/n+qG<b3DEhcmIT
5Sk:>\R5:--D4O1[m4,mj9ck<-BsKG["ggp3CnQbtK1SDkQGo0>ju2Dn0pO0-F=mE!l%7r'P
5&,(2A0@@>&gKJr:F6?VW18lfB_sX8NL^G&5=2OTD*lqC&Q)7UHplhdoL&e0'LY@!B@K/[7e
;M1pVoSZYTFVk-Crc%MGd!!$S:&r8PN!"I:e@FN.*EA:mdc5jA9\^<r9q<Z!dWGT[F(iE9R_
@`jIr#s[FtCQIh40gr,CYrqs!kj=WgrTPkEVI_taT!pZFVP1]Au1#<_!06GN3HFZtSTf`B(Ic
\'F*ni,'JCI>BU8e`t7,FMK2Ti^/oNQ"$bS_Gj@m_H365tBGC!'hU%>YPIXAsshp5AkO<<>e
qp]A\T<m^>&TB^@0.,Yap$5TWpF^$e35nO%MT1[S[Xg^L#]AKZ*8&687Cr[!IS]AI3nN1ia-WV1
&C`!>-l`t6C_6fX3iVf]A?jF$GOdGI(O?u23"Ish]A^_7[]A]AUA79(_nohV:Y+(J!b;hDCCQ\D`
E-]AqNc#1HC_uc<>[gj*,e%-u7r:+agS8EL+JQ!>7G\n+K`l;"!IoOQ4@jIXB'FM!XNdrqjGI
%K4nN3sEln?-5tb_n7YIo!79UB<!uR^jW9%)_qOg`']AWed)4Drf@[K1<p+3OQ"%+J+8u1'`<
?.[QB9#4ZTumc4$lIc<BF8+6i@fL\noc),6C1Xe<ut\<@!:#J'\JI@EX^lhb#8@lg@a#1Vq@
9gHOb\X=+C!Y$?iZE5*L/fnD0DQ!gLl(Nk$`"fBd=,/8tS9S6;?CBHY:A*)RTY]AF%%3dcoB;
I6LF$kFLeM#d95!bU#$c`r#ZU+_?J2#1^]A0+ZR9cb=&a<D7+ccir,dUa?^%NdY?<iVbn-9+P
TuG+-tARGp61,NAa0b+jLcrtRg,kt4r(5'\nZ)\b[hoR.cgf,r<,cXs_H_tF8nZS"8^U,.a'
A5]A\T>0&`cP9,OD.^$6Dd-TKeDQ>9YHgNJC2Q'EeW<R)Or]A*';#OO$(qd1Eh:4#b+B6YND@K
p1[]A4h2(MFFH7&**S6D52I/-DRueI:I_D,-6!RjS\!#qc*Qn"iOFq-CGT>AEbo(PGb^L9(ZW
l^#)67#k(<in?;F(k8!q'_^XOd36hX`D0$N-kMLeHGa,ums/4ZR+p0%ha*9l=-C'O)mPB\H:
lLk0Er`PcB8NGM4NBm]A8,JufNacoXPGgq9;tXR"kV!2uC+b?aVgs!^-@f/IEQJ3EcIWHa\&k
!`V"jh`+8XdP<Y''2YBkc?G1RN_rlpO*PlggpZEiLPA?5VGG;'lpjO"]AMkNk``q'ZL165t_I
OhqOrJH@pbiF@u>qWE?/ULOd).?(C!OVGDpZm-j;IoJMFLNX^:K^#doceZYb')`dLAQD[$-@
ejucaH9ss#YZDFWV"d+"np(:&b1XG-o!EoDl:?/Ii=&A1p$V+Vde`/:_TJRi(G-g`o*M)IEK
:#qJB/l9fU;mUT8NZ+Qcl*jb6qShf?^(3B.Z56LbE%?;j^NB>@.4QK&oeF6?f.b0B5TC\[17
?Wb)i$f2h3-C"Mk>i$JMkXUW<7"6r-+"6Gk1phW[EO"C.U]A02S]AOMJG2%LU%h3n@_[s7$_^L
@&BL]A&1<U4RJ:Aa"UMb)X<9n[`3K>KP3NO'+a/"W,Z(V48H;N6YmJ#;>-B'XZ22/Ou!:FG:V
aS5^s+GD3@522=@4r9:l&?gS+h5^cF^o6-S5^prC]AT.8%dD^_U.]Aoo.hg+uJdN,[]AT&)RSS$
(@5K"V%;_&]A!7Hob5j2(#rP54:@lnF9,h2cfSF[stsVY?3Jc0\]ANlg<0bdIBp)a1lP5o&.rq
"r0:*pc-\7!4u&<REnR_V_>''sY&j2=gh4;G*>t`+s/.GmMQcC&RY<i3Xc?Fu46\"2XKZ3h[
VacBd]AmXNl.EH3FE6s0q`F\'J*5SXB$H6V0qM6"WbOXp<;.abX`p@nlFX[3*`FNTo.o@h$[0
>^;&lB8e8m;n[@I[*#[@Lr#@=sMQ3k/&-/4p0ATpnaVn?kZrn:e4^9Trm;67foi'*!Gr%>PI
^V^fOLgKrQLtOse88dbU%O7K>?lIqbcb<+LI)5*hJNP_>K49Pq[O]A\mCOEC+=P\E!&"bPSGm
nNg,U<gEqHEX*lr(/o/N0:a<<_H_ZM0uHM3(`f]Ad;]At9Z*]Aqf^qsaKaU#TcpFb4PV<gKU*9l
@gOSg@L[8U)%l<Dpk$-GA_[$F<[MXJ&_;FY*W8kct:.3oY1L#Xer%R<r6_m1Ys';t?cZuR21
E=0Kg]Ag,5F`rR:A05gIYKj]A+AI@95+kT;65c:pdInkgR)MTnC7:Hn]ADYp@9rZ;urVHcU)B!8
t3qKUG2#pfb(mnMY6CRcJ[i\Mc$<2Y$Ki^-&W4me4#XPM2'&7f4G<]A.F]Af%:f^0L0:q^c/s_
^_&J[?M>!T:bgiR9q@UU'q[aQ5D->44e"nZp`.Q@DM7!ZZ\9N2:RXB)F'omU@c-0]AoV6d,>a
G%CNTPGR1jEBLW58Zi4g^X+ep?o44I7R6nJ!u"3]AldB8I[rGS/nju0TT>k0(&1?"d2>[1NBj
kg&WAjqB4H?p1E@sX0iVjpHuu2IP5(1_aj^8$2g!UpW;h&NGIFn'+/MIgt[_95,UOEf2`qG3
)'NB0-6DY3uF8r-.mLcSW9br"pH.-ik$ER[B9:[_^5>801;r=S\]AZJ!NO80c)Z-LN=,0YPgA
r3c[CY%3[\3h`J5I[cO^Mb6U52'3;acTG.\tDP?T'6T&.AZAs`8A*&1u><8;9TZl%NAUsJ74
c1=ACg;-BN?Gb4gD78V#[U'7lH#a<"\&rQ_;\bVpl"2A&SD2A0T0.u6q:AXO;$VG10?tc]AoE
NfTI&5=85`u5J=>HHkT0;JN<8mR8:dhi2_/CX))C,9/%>r=GOo&4!L+Cr=rUUaMiGOeP\a@"
^M*$LrLS*LK^ogs+^6]A76Hi;`oRF%$K\O;?dG\ESXL#t#$,j:=8[FL1_bZAAsHD[0!B_(4eh
s[Q+GPn\g_`AodIh,A:*HFH;l[Y/>]AS@-C$gGc@LY%"[Y`6c(_pi&:a[3IK7d=G9Nr%gR]ASh
#X$maE9FJjHBBFe'1XOhE"[0R:^NDUrc)c?jpi=pd:fq;2@Gc4C&XSk'#p_K)GW#^CXdG-gQ
.c<Q]A]A;d^$E'FOheVQb_-'\DWE1$a>cosjIr;7PAHie8is/JsYo35o.6+XBeN-j#Z$u#tbng
L"WXZ-,=QIk#!A5k.VIZ1;VpOipO-S0qQ58WRt&I"1?.]Am?KX6bJI7nCMF86O.RSDlPB.1;*
2I;GO(LdI<rKhJCo!VeH9T?mTPjCAKqo[QbD"Gc=Kp'Hf'i>jfoXF!E44fNVZ--O?)`0WoX=
k*$RnOED9*jdNXQdGX5`rra7Z`)U%Xio>VXA4cuLW?FSlR,Hmj.jmn;q4+6GipA+M_Mk9c`J
s5^_Hu&X4RZp&4,EZi+m[]A^At!Xg$.,WJ!oP&6Kip@(:u_YCNS_'+.Zbc0nCZ/f7%D);cn]AB
]A^t;Sfa\<=g3;D3f/bc5/;Cr,CIS9oc#ePjW(27/X5<qGpWVN+QmZ-CQ=<)@6pV-.H8cSCl^
>FCEU6tH0!g-7S(JEs*+<lFdD%o9e"!L#q\6JZBofHiGg__7SZ"IV7QL\*4=KKeFP1!P#4=&
H@hX#m_E]Ans4,nl!\\`b!7ra'pBh'q==JZgI4HG2b=u_'8:1G<)fjaH[d9R-/$'^&Rg6-FD&
WM0L>5S>hBnPokFgsg<[13A.e8apjq,;!S/edjjH;Z>gId:It'arHDYPf\j864Us9F5indH2
9Yc,r&p`g7P##T,hW[OB:D(r/h]AXLT)/7^@)79[5>t&Qe(3HJ(bUS.9_+(65uVBupPSKA<rD
#KB?]A;(pY;0qs-\`H%2)?+DT9jl.BuO]ACJi#F%eD9=PLPbK3?>I/C-\>J+=gOU7n`b()Y]A8]A
2BF[7jg]AS>,RbRq-n=)K#M!b#EWa.8k2V`!"\)7;Hlc@"P`2X'lb?@GA*4@Dt+P/jqcJq!Y'
BJ>hZ2NpD$sDJNd[W&<gYgmNZVk*&1pU(H!L=.Ygkol`?5f/AcKNWs9K5,hJ$Q.)6m]A1)LTM
?!\sQYkLL>Q"G/":A5!X<m%%b`^YFRuBU`mKk=r`IV`WmZF-4AO\g&VmNG_I@C4*or*32nY#
,W?SW+D?VAtKi^7JsbM9#>k,[7J58s'<r^%Y@7(lZE;:gFiD$M)KXJR3#qq]A(:=H#-^@A9N$
rQ;JSkhE#1)5S!TH.$k)K!jFi0:AC$)b&*a`8Md-Ddj"I8q2Gbj1M8kZlrMJQ*Ci'nAsMM((
kJc!!N=/(5tm'Ol!"Ca5@l&SSc+a\d2>rQh_acmCJckft:grH4qGJnn_B.F\J=*C]A'dWaA[\
3cH!Qrgog8"a>$8]A3kMp0]AW]AYDg,9Yl.T*bn9)/I#KD*dQ=?Lj6[_K4W(&,K@+VGMuTK!/QI
/jLs=gU?f>"2BdkV@.aeN;":geWNN8(NgJW+!V!V'YL4ZjbYZ,JR_S>fk%!^VgY;(6/dra4"
7t#e[lWp&\1l6M6<4kq-R6`F>$Qrn0sBi"PCi^?V8]AluL*>2ckhlG:c'T8V?^hl1Zm?9RYr$
O*MX(T2]ALd*.BD]AMf\Z#Pa9pSpa8\-"KGdiT1#PFF.IXCV:k:,SSmRebl@'SH%M$5Sr)#^/'
)G0.))Yf.#@6LS(Ti/;]A*)\P?W3#7r_#Sa;k2;:mY*81PpAaXJeZXcf0;HiIXZlf$h5:#.g_
S.a<@qVFBNsnF=n)r)j5jbQ8en+<POse+gql.#lGhgk!$uCq@9]AT"FlBam"NH-HqGYdGe1nb
-&7+'_\X32Vra<Cn)Is7OuaAAc+#eps\i1SZ2MbUL%K>W$Mr;UPckU/^ccg-Kp&@BQpNK1dg
lGL6$'WVTD'7fm*HYe8E<YV6^\qV.5nf)8G7$Mefo-O[]A-aqQoMHNoXZ%ZEON'Il[/Z(]A/'5
RHF93O9OZ'03K0[9U??SE^r[)l`BEbKRDpT<GQ,J*6g7:B%d+9/=b71c8caY%6q`5]Ab%O':-
>*u]A[)JV>;Uh7#KOGqKo(Zk[-:<86YC:GUa$dU[QL$B38P7qTA^ag"G^[G_DYIPRqJR>j88H
F3%.</`[ncDWP-qK+P.q;+:1>GUA_+(oXFG>ibf]AA]A*.*l3L,BcD>A%i=Z:Kbe)006R?<'r4
s*-jA#IeQi5lXjIOeR,p?@p!QkhQ:cY)^?YjkSE(nD2DgKL'9@DZnL*bq^?kH$5]A5fm!q!g[
?XfY7sWiaA0Wju*Z5H8E,fB:$7J<=69N]A!fF"oQoIYA?60an6BSBR^7[NaV1/,du"(]AI5%gO
6uAQff\^Mof`iHS>_9gUOLB2l3l=I(KArKSou'Y<=3dNp?TI=ld)P=r<gSmI$jZ:+dt`!VBt
o'L\.X^sl+tk!"%bTb\`Ai:B6)K'IYl'eeXkk5ZSjANcVYHF.G:6B:?"AXT69@mr8a<b%d!q
L2\0Tu6t(_\RoLM5a@n`+i89jcZ1#N#)E4hJH#KtsT8Ih%\#L8;ZO.3K.5D9YT-&I^_94A?d
bZJ2fqirT?X1'IGDC5>M@T%,V5H>FeXmjd2JS>B/LLce44Rl28(Qi^]AH.lCCFA4Uo\E]AA8%,
<MV!KBLWdI=]Aj]A-BL3]AQtZVdDNJ\t+N86%_O"\_p>69NschkS!I?dST/=\g')ZNDDV9-Ri[)
(,[``=RrP(e)*GD+OaPU;Fs\NG@ZTK\#EXFqVOY[+LF"P;u8]APF[De_O0l?tGP(2-)I.2?mo
ao&%Q,;UO[>IY8=-<Ll=.CV0(.EQ&=1':8=>fFY1FYaLBj/an`^?T]Ac*'':Tefh.1&YgQDnr
,B2N7[3-o]A[hfjsu2W;`V?5\c7?0T$3`h'L6a3Pr[7MgJTgt3mm=<3`I"c8%rd8h2,k)tW-a
n@L]AXH<S<Dlh]AA"i3e[hq>`YS=PVfE9),g8m?OX,d'8=0t!W5)3'Z+DG^-kFMehJB]AlaMSpk
i_HG+:L*imP>cOWgLD#X..]A9Ze0E''dXr@=)=kaFkAjX?4nZXZd64n3`5?2gk16bdsm9uNaY
"?k+$E]AdfRl<quEF')>Q,O8na4Te2jf;:5`]AKP#@mWI7D75FjWOg`O+mDFFd\b1tkKD3"<9f
4!u<gB&a<l`L2E5BmDr52HSG]A'd`SR4"Fj7d'U@q9D4R2q"?n%&[hDWi0i"1d.okQUc36f?4
"=9E:N14";Kpfp_O*B"dj(W3Zm2LHp'UV?8X\GmU`l#4q)rJSbo+u!nj5<1E35S;CsLY)2Al
,H\o&-A0"5@>gZ76K@XL+E7VC#e;ee825O/j8SjG4Vu>11lX<LB"9&=qTLU48GG/)fIZ+;3G
]AqV1#=^a0BmB".bM01/_661Z2Bb;cJ;+TDUskI0U8b\Du?M"d0'7Cf:Pi>Qc2SFDg]A;kc`!/
OZDAuP\%c$G.qmoCA1qsA-T(G+#&(!2d@DOmY9nD=HC&N^1V[Mai:tDrOq&p.!qNN:0Ga#do
#l9=P=dRkXJY!'Za6nIe:u.[Fm=R^u%bGHgZr4khtK8iAtc24;\4&:T7fMY\_r#7OaXeEQF&
)DG6Q*'Sr0IKjHHs"4[BndAX6<d[cN_V/f0op7[0q%<s=X8KIE?0W6`_jX9YI0nsg]ARNQNpr
2-_pI4u/99mnUSR/sq([ZIVe]A^F.dec/'A5[3+eogSR[9/((K]A%=9E&5ej`LMrPJ&\;b&@c&
u.i)QD_Wagt4*&4M%F7HgH#BfdP8i-8GU02cFcbA4BGAZ.s`0$@abnHECb$1*ZC"i2^fXs:P
^(VPrgE<Mf!@+[d1N8%!.Xr3qV$Whk.n&bA&1+)o7V8n^3m&TLg!)D,DIg-dB-15SDf_+C=+
:6A@dq^'&:&(f8;m.0:(,T_MuSC+@$2I<f;0"DnY8DK*LJ2)=>GY2/@VDF;832N`.1(ieSoQ
IUHSjYLTq0)6tofE4CNm>=;C_3V3f]ALFZc+(.'ar.*N-0'Nfj)'s**KMB'iY1DQa+*^*0u]A[
g-3c'9$u`Q'4[gc;q+tfOe88Wok9Skn`7K#clE#76s,$P>F',?G@:sK8m9cT5jHj&S9]A"6J,
b"fLWc8LRu;0!ME*s!oV&,S%V-BS.k!(DkpH2_dSg-15)s4+N?AhLP=;0CN\8CnGp/GCu>B`
p,r01_dLl4;aftnkAj.<U*S$TW'LA"-KMdW59la!r(UkH'5`dn[QVqX(ks-)f`.u+aU!JYO-
&tBf_s3dpI]ATAooKVkE5jiqZVN/cM7)Fg8fcD:X<:J]AVn=j2cj,Eh?jk\o*TkKf)W8%W+_dB
E(oAbST5/"b,d'tgT/%\l\ufb9Qh*GKDC/$l14+o-!"GWF$dpJh)\>!LF?S`Slk+ehT+$haQ
n,Sc]AOPtM6:EnaR*N@8-0V.RkI-MOCjA7hN!>DigU6P(g]AJ,?TpqCB,kQ2?>@=qR29#qYcBF
nZ.-2u"R#"d,(l23S-q=:-o3,B6L@oJ[Ti'3g:uFdnm_j^+OdrY$_Sf\Y[Mn-<J"rP8B&Up7
TYNOpZ1q$"1u<'Dn$7pd`10p[miK8!-F4>Laau8%n!X7JfM>:HqO:fse$^'IiMOV(fJP(/i%
Vj*E?O=8<.OhP9W-Y1;n&1M106$M5BeJMBXjT4I$Tk0KsLY!rL#kSd3LffQ8"8#Du,uXoRB>
h%C?.9ahg]A'l<dSTrk(/ADJa=1WX<$f#%j1aeBDd`T"-+c]Am8Z'>u0&JEFLI>osdF(&Ya6]AC
u1q3A(deoj+h`bH0``>pA5Z,\[P0Q0"3e*TgCf]Aq,^/CF%[R/:\pL2C)keT?_eIE\K?6@I^b
@'N+`h>H@!==K0hAUK8W39;j.[,^!>c+Q[M".5[k]Af__0&UqGCS0[7;FB3MWYOhT_:Rg25kT
_fpe#XhnI!]AT)C;!QGlLhiKJP=<pm$RgMA56Fc6.$mBWqMaiFC@KOQZ-/jIB\1E1'd@5`Gi1
FJcm7UIig<$bMYWpkq?I]ALMEqEGR+;PeQ+q!qr5?DrtaJLeiB*#k5fj3Z"gsOs.1EV:'ER6f
:6i)(l9UgmZB$M+@b*t1h<%]A/M.5'/*eD!"C4)[<P>rLf/0ii62O>/H)d>p(XJ"Y:er9g7@%
5j>)81n>8JAR;:!\#C1n222&c'\Mc-S<ZS_\e@bMCc6?[g4dT3rH@`@FP&:qQSOQIb!-\<ll
E)mBp%S#^XTm@X`H":115f2<^5!Z!=3eS>Q;aY85&d6>)"K!g73IT8SWRb8gEHm`U3)iRM8(
.k0oLBt.a??X$PUC_(Uc0_ACEI?oBAl?92P=(_k^"_Bg#/33*GEGE:@_'LfNFQ"GBfGL;'HZ
F7AoMI4=jhR)eN&*)P$*-IVU00ClIguj2fc0['[IJ=l2a=r4%2nT_8)VJY;UP@I3U`-:I$!'
Qp2'i-ea2([%i2h3*"Zsj8R^mMaQL3t$=AmpMfkf2Lu\`2\%33%Lo\-=%3nPLQ:,<rHE@s?U
c<^*^>r&6--'80>9$%3`DfW%V7.OIdGN?a%8W2jR3Spqb_dHrh3gI.D*2H%:UZ`mMECf4^Ek
"KZ4)/#9r$uXcM#sWOqGE07i7`s]A,*CjDhbCD4<$#!V._$QQJsA:QCbTIE2@po(dXDhnM,=e
M'L(Y+e!_]A<P]AYsOl61,(h)'n>96J-!qof:"l/9J*72Ba1*WC::L`?JWubT;77u'//6"k3Qf
SX1L9Zo:`3BKkZ3s;MW[JFEXQ2\KnpY1IhTeP,4`VY5+F^Ckl^(]A?/+f0Xqet\6/>#.mm36*
:^S'*-3i_Hj2rB"rrsaNL0#CFb'rik3_I7hTbTo.(b_N=M[5[_^BoO9>mEJSD,3tpQ-8soO[
,Z$$&I+,"<dO^CjKjrC]A8Q)fZFWe[o@7,rbca']AXSZF(*EG]A3d5rN+IXB>#b/W11[(o!n\]A_
3MT)U['ZHO4(MX4b5/$AC(?s#U6I=q``\#X<k;ahHWLo^s[5N!3SZDJ`s)tXj=;lX"a(5TBX
$?WAHOpr9pQ"b%p::HQ(*M(7/^A`+SS>_C6U<^\Md?<F!VMtg3)J3ni*>E.]A[T'H'9]Ao4'^A
9%*YajZN?+k18Pko?EZA0^G7@B3.M,UlU\g]AX7gfAacX&ufO))"*Ir)SuGNi_k0G+3_>C*'g
4r]A=2>p\>1ej_jg@=h:/5fZ(%Ue,%:_J%+[BS`->caX?-Fr510]Ap>RR"k3bQKT\K0"ZR%-?S
\48k]A/_U"?R"9@-NID+2.ksp9ResU?P9mHk%9(Sfq"?#^:H0Jli#E^"`X,mHiUPD[.CjlbLo
F$\;Gfohg2_1]AZ&&+csN9ppX5b#p"gX[`4T\14T@N<gZRcQ'6h'H&A-$JO5G7H23t5!FMFl[
P(m+XD[-Q+afe^[%%`QF<OZ,%/g)sH^Od$h%cCg8#%7'qJTLKl@Y7hI,+eZ<esPH<ooN\T;2
;)0Y^O07V's\L>8<McoH!?c)SNU@\3FRIk7qN_O,[hHZ/hB8CJHI:SAbuN`p?d1m*@^t,]A(O
TnKmBoQ48q4]AqJToV0E/2%$Z(Y`N#UiqrK:U?Zbb!kTsQfg`L9j1+flJ%9RqGl(0Q.>fjM@:
LCS9GY%86FF:%\Z+OM-n\-Fkoh>U'TXk]AEe"6b+C!40X]AtL-)]AH7*?V9.uC\1d+?:4-D#+f)
Vm\bAEqXp912H[5,FM![/Gj>l,W+M[\eWA`<b>s`Q$k%XYa,"g^;ZdMG<-:!r%F#D6=p%FMb
#bu4bZ*=.rL)gYr!<LPlR+_9u+Q.<q"mism=N+lE^P-),j66"T"CI26nujH=S!YQ5)>mk/l7
)*"C6s4+^pa&#)#)A[;cR3u\taR@0BqXL)r978Q!&\0EccHrW'(,O8O&4R0;[VVHs:Ru68`*
3%J3;o#ZNu(J$=QFZaPuk^E_!hDEDM,#0B2WJ2ra?F7h]A-rnAk.KiLj>Vs8)t5ioILUVYK+H
H]A$rFlLSH%GLF5Ln)cY,Q0`cGGNR3P'UB0)?.m!BY)(>aE5QfnB2rk]A"jFfZ@,`+`?+s=\O?
9_0Id%DJhQbs8:CC`;hKg`@*9liZ^Me>2Fb9KEO\f.IchG&_#\<OMs06cI,(.#e4-eD)=b_3
/Tl"-A!0f)a'H^FC5*F]A-)EF=Ci73-%\Acc*[kR%.n;\HNa0mS4DI/V\b^TM1ik$hc/R*HD=
((Pc'WYh0^,XMVJed]A6su!H'rc,(;C=t*R^DRT9lBl:;,nf1a59h8oKf:GfkEm%?rK@9FJ3D
A%oa-qH>lg!4GMk2B`1F1^;-ZkocBL\e;;SV_4CIjYH2H?2f_g7"cR2hnTC5A=?cHImD=uU9
@.;@F-^!I<`62u+J#k9)#6/gl\VJnrOtgj]A<1j5Z*9FPFD8d^.m$0H__1_@>-p&Bg4<$kgja
D!ghanC]A93N;]AP.5foE(>V-W1V-53Rc)Hf#'H<RV-<q[goXCUYeTFQM%FLdfV53R%pu>^k;u
>.a^X^i*2#<u4tj!Xm'49-Y)oHAp@Bj_ps+&/2b\N8Vf@kf]AmeF<Q:)+<H=>\i6Tp!srTb3I
]A7cXAm&VdFmj:GBQd$55+E=QeG;%l@SleUL@K[2VKelZ[VA(iCd0^Im`jmR%T8nB/WRcHqJk
\54a&!="^^`H9AX\&#>Iu'RcZV/lEXZ>s?(#4#@;Z289tV119%G5g_bp+^u:FdX[mJIB9qRj
_3lm2)W:,r=*XG?Hpn7V$>GZ#8%o?<_^_tNY-:dOu.iC![M7MT&n9pTI*siJpoKcTim4\lBj
PE?>1&n9/^1fZ..KAh!<+.K$nd(^!EK^cCmor(kXaC4.!R4eE4&#B]A\jP8V$(d0WjZt]AU#'.
]ADq0/p2j9GnF?7:JAjh'J8P9GHG4W7hdp(2or'sAZ'%&Wi<tU1(l='b@\6LpfkMS"j*kYn9-
e\p6Fhh\ACX@(^nq;P'2BA9T8H4S3.`T\$hI05`^9R[4EQ^"rIHg[U:k-el>5Pt(iFZAU$jK
Q^&FrJ)[m/l\8.ENeiD7p0ZDF<2QS>5lZ:XW1Ek&Tdpba82UPGJ)L>^7Bse+3M>HRR0Fs(lP
FEh_D&<#`i)1d8GbG-JOl)a4II5b7e_mU;e8[/rl:I-casZIa]AkID"B&Ruq=5p2HcuR%pPZ4
oQ'mclp:mF?,&lt?mes__H<J_(dgkhQ<TmkS;RA;$l"1ZKLS*%F=G,>4+G!DuiAgLaX$9*<=
_&@"X??0k<Ea?o\mgmp6KJ>>KAS299J58l2P!=\D)9<BnC?2(;=h3G%?Ol/-q4,ANpP6MWad
mBR'\(#A%7an!;6`&=KVnPY_>>MEZ;@m1JBrLt9Ekgcf*LN[RuG@hogF.dDQ''Imqsfre"Zl
lmS'KX;VF\hlU,o<!D"Y)b:S"UWeVft`Nh3CWC9@E'VIGj6j'_6\:n2kolDukNdn?7/[Q#G<
^^]ALqSLa4r9#%Z0f1%I23<SVhm(!BFT724265n`@_sQK@]AFlX2LRheMpfNM(2FB-S5+29T%&
EN)fr3jfI(Q(9`1@U?C&1Om'LBL$K,EDbQ*CI6l7)>)eCJ%?+ZqO1:,5Z;;BK$fOJ<)4h*:B
'-NM?YD,*`YdBN.KS+HBbnI)F4]A-Upf4TgLZjiH'V8=="E$.aTVL5,K'.F?UUQH3:&Df,c\g
TXFafaEOnJgV@\Z4c4C!5GLC**a%!VoOPJfFq+m6-^Bj2#TM-%WneL;LpHQ[<25Bd(jI":.U
m7D5mhHsS_!^#V-Sa1[nb9cr&(anoL$7:Rb%B^)!,V*+EOKOG9]Apg\fY^JuQiA$,oe'I3Odp
^I]AK*@gHSl6Nl2SK8P";_@tDCm7%4:]AZ`/&GcR))sD^,9_Cr`R$Yt.k6K4M;9GWVKct^WF+^
,_85.,VV,1uL8:Z.&_Me6N5l&I\Ti:KbF-0NMWl(aJ='3d&[>B?(.D.<%/M8BA/pN(g)C%Ar
^SgqO!Peb#jmA\`q;\rfC9\eBlpC&S4$H%!Nf`?>ac35A[q`TCdMJB3T4He*nqFof('C]A)=@
=<k^mL4XZI'=Be5:?jm0mJR8*<c,'6p!0IlrQ9V9%7>3kV++afXK'.qM@!Wu=Q&qpJ5$)A,W
HYDZ3+Q'5,$/J(FPVm[>WW210\oo5\K4%91n5;[lRA6CP4eHu"r]Ai%OWj,ZbU%W+aKP+f>$o
i,*!a,CS]A2i'K2DbBa/JNI1/WLUp^"L10jcfn(.\D!UkF@#mHQ_c)h<NB-K/!k7V<8/^6;tR
c>pTIS+!RGZA_M7PYN>M;8e.ct)1ea7N1"[ifGRpM%Hgc7;<q\j(hcgMJZO6jBk3=oOO9I\J
Dc5W:@Y.H"Q7QYH2<%?ogQR&df&"G2.dHZl#0R]A4cRs*rd@27JlU\XJ`l^91bfA3Yi(,@Ca<
FoERkCfLJa'^6V378(g_,+T!QnlI":>s:/3gPOOC\=/8\jSD!BAa!/fCq0e>+!p@HT\LeM5Q
180IFsSt_&&)-pGU[ii^GZrS6+,6c?;f8pl7><('?21LJTQf:;h^)*Ble>q.MjtFJMl<e37C
7>Y"G%]Afag]AE;*8JHK0aej%J%u[Hi\neE_m.a0'#YHTs(^2L'gE,/5T#t#CUrM<c)^7@Ae-M
eG7TP=__N9a($LG82`"EhPI9\)JB:m]AUQ3"iMJn+Paj^^-[A[J9e,#:ZH%%R!^Dd98:k_kTK
FehXq22uAXWg.*4I1mdS["5&K_p74,2tUh/bf#\;j]AN9rXl[]A6&Vm,pJ67[g$@0oRTu'lH\p
*U=c-PbDFtXr`cf9$Q:kS(E@RGaknU9,B.J79q[%7jpfq/:4@qF0eHajb)dVWDe*G1b[8d&T
,4eSjQ9i*C5k$JOa+lgSh7lF5p.WB>pK'`$Z-!<0.Ui[YFQOL[VnA;D[$1ChYNt?iLIu]A>67
V<]AjSo=KP1N?C98W9rtD7rsd=WWi?]Ae8uQ1GX`q9PU[9DZYROgakh\g?tnJI=n*>6U%mGSG=
[-9F-h.'Kn7#H1-(EBNdiiIT\uDD&\hpC]A%<ST=1<=R(lQY/Eo-33@@T_(PeiBm(5HH^W,Lj
k/p^M:X^$Ccr>)p!^DUKA3.-nSUQFlmP59!4R_EH+S<B;W&V%YVe<Zc62KU;'ktsbhc5D,pQ
]APGp_5S5#p\TZroc7u9I'WK&Y("9c9?Ms9jN.\4:R?[-uE5R#eN&INJF8^r?%E1XrL(oMZ-=
T+DsQm&qVbqE;XbL:>ML-m"Or-L%(n%n1<;0fcPjhZ@hEVKA!O8+/U82*P=Yf8j`s@,6U%"M
*omOD7ZF!@spnBQ<e#a`*3kNOC+t\m&:>m8ng=j%8R*#*AOk[,>%-"`snG6\-3O#"ELS@nH$
i%ZQrFDn&qQE7LmQkk<&b+g-]A2Eb;,Oc&UioH(psjO?5:kO(?j#WD>*.L<78n!B\"G/>^`-h
qXSs!R;_?7gm_JdnW`$el9\p(8"-R!N>mkDZ8F:**nMIX,8ss!TLU7`-EgA#fFaqXF$bsKG5
CC?E4&pY./F:V2IrCW`&ND,rimiUa5_)A\c:=2:DIH)@i7d8V\<7]A9:B@,Xb\D-@WlK[C(.`
l)Wb1FSn?.+.0W?VWl<M1K8-?E@>=4+mu`cl54a3;(e&G>EI:?FhaaW"X?m7sdi`\*L<tgZe
fG=e/@>6>9J=?jR.$W:M@>-O7E`G@]ATXd*TWX&!;;p\o&`XbFUcQS+f$^-[l-u6[c3N=A5,`
4BeUg<=1i!c$@?=("'P4epg%AOfV@urt6GT$]A&5R>=V#tH+6:pFjRlN3?Vj-J_b>r8s`(>bt
MmH#X1mUt;Q]AhaH7,G7E7dAY[GW,c6!chQ(5V.&2!4MOi?R)@>9CKQa8S]ANL7rY&W_o)BS1E
.33<`P-H`@qEYY36k"\aH0<Q@@Zj8V/C0+fHHgJ0HPUU?W7aRrHG'C0&'gN*Rhi*X:7_GSjG
*S6gH/"hJY#\jEUdhX@IHNi.Lme15l+0OY+`'9;,aY*q/o4\R4q8qUkJ5:hamN$0#f6TOgOD
2YC]AkGMaA1!a_hjdWn4Z^'bX:rT>Q??aq+s3r&$QGP)>0/nid>o_K(.@!Wj]Ai#>=1SuOq>TA
,3.@".cW$I:#a7_@MJp&*O'Z9$f1c1W*5$1&j%h--MXD?sg3opM#8`rM'_`OWO[HT5\&d)(i
R]A9Q3=\-Kt#VcA+Te^GsZJVep_ZHsE"i&(LlZ+@]AKH08M`Qj;4gN3.)N(7I+F^PY7l;q>#Tu
*`XBG\>8(a@@ms%SuNVu`ub[=@p=h@\A.BsI:CM]A-YmRf--\6F1nSW'osi8t9oOL10,1!p9P
`cfA$7dD<9?Jq<//4rG0$X.@_s+hkBpiLV.DY5QYdDC8S9G3+$/E;pusD7k@0VbH5MO'[HZ?
-=hHiS#&/32KsiJTa,2JB,OGVft=#N/s4=Bf:*BW+]Aj#G#,QRbqWP@fj,t5/M(,H+Hc[%+Cj
+.P:lrgrlbPkmPhuMr5_/^n)A'#@A)FReS#8_o)(Ub=IM98jac27le.HA2i^A>R-lPWC<Yj7
^Bod9[Lo#Wl]A35aCr2i\@]ApD))`U=RcFW]A5"DA!`L:S&1dHW]Ab['=%2;'R;qY\D$<EHt,E/[
EMnk#>iqX_khmB-@368gW7iN^_HT7roMT>iB*qe=s.2`Z5GaeZ%[8hOsKKEE2!6I61BR;56J
p#Xa?F[N!f`DP`5:d4@&QE02]Ar:*pj*0fg*BVp4<6>"JGDAu[X`,t1=pJ2c.T3+\V]A\8EJDn
^.3@<-PaO8WUa<,]Asd&i^2Q1?Q`@'#?8D9DM&3bpfagU\XVNn!L8<.-ahDn>Lu>:<HmD!TC"
8kReuJqFQc"3M%XdcS2S93X?9%R$Y3PP^Tk.LjFdFL5+ARMq$PiZ]A<0c8^$fqp_3[A'V)R,3
QB?Q.#hu(/J=q>ORi2m-Tl=1N;N`NRQekWk%=%+rC=%ic^l#t.FY?8b>BKJ[`N+>\)Dn"0[@
FPGZ!4T&m)&AqC.r]A^n*h'd_C<ajcOklC,M^%S@R^AAdVXen$*RZd"17X]ARNT*s`Sd&:XOh4
K%:&#$Qh(a,>Lb@NXW2[j$,i"$S)\Vp.-'jNS_60@W!-68R.Cd;-\RU["qMsC0`$7/lY*Sf<
#J:n^:Xm0e6eB=>QIF`-6eA6,a#Xlhp%"Ueec,<GuCbrGb#?M#u8^[<.:XCf=m>CQ.0o$`8"
Z=_5/RgfO^]A<2BZg'Y,,8XAV0%;YMqlSleXe\d:SHj]A0T`iAdNliK6e9T3R4S==Qu83+nd8h
W$#AS)I6*kB/Ug:2Y*^C8Y2;!$uHh<;/m)e#c1Pu;dY;'WFlo&&]A_rj""QSZ[dj2o]Ap`03ME
@ktHV,o+.hDNe4B5W8dSYJQ=`oeBL(1W:PFM0r3Ni>M=j5P$,-6jV5HQ?^p\t$l]A-/]A$<&rt
@S56!0"Ll:nJWHYZ0NcCG,)q#SQhk2TC45''U6s>:<T=p%bS[`;@*JEZ)q,XrhpM#TftXAec
4X[KbHPoBk!BM"a/th=@^bJ)^)2N9-3]A"GcXf"[6;n'Ifg9"KYH5.;!K*m$Z3VfFURhj_B,Q
%#<*Dq$e<IFnHOog`=V:upJ\AeUEQ,L]AAE<fpn]AI%aFbj6E7Bh69rM^0Cpg+'kCrn4hA3N\&
+9ng(WD@?"Z()\6&W9R8*)'`+MRc&_?l1aEni4TNT/D]AjQ2DS`U0L0h1tm[oBAg9LQ#gHlWP
i"D\KHsqfNGB8C(H<;d5>:[4>Ugca[e$@hOe><*8;`fe=I7H/g3L[2#a.Z:F2d-hR.2$_<"R
&`s&Hk77-gi,E)@uVbr'$HA-[h\Mg1Ed7mO)?(R>$H2kC=WF1P6ggo\^f75/Vf*4mFAg!)"`
6X@mTX\+PQeQckfiYkHZVH*r'=(g!lYnYJeSV4im^ChG,#`t9`GF<J=agNE'DI9)`QOQQ9P9
6>lQ8]AGUTNDH9T2rSPk-hk#`;(,+ll^ESYGAGX%:"Zcj,)7]Ag6*ZZS@M^*(X@r&.tMm^>T1j
=$oGRdmu=Tm/@d#QF*Vk[A?s4dE$)H.W6FZC3f"RAGjTWMgn<6;ipDm#nu==gL9a$e\2XRo#
oD.j1nNK'm0U%?dVDB)hN%bKIEIq;]AP[V3c<St*U'qORd7?&gJ=aUhn"\FX!t;mIrq>`*S&/
;h[`F"D(ZgY_9<NX1"oc+72]AWepo/0X5p?6CFE4TL)o(`X(M">8FuOB0R)fL4:hOF(e[,2'Q
gU8FPc%U@^2OZ6RnX8=MTW0p.?O6@k.BD"7Co@=/,!Geg=GO[E1)?)-1S#,6:5&X)NtgUK,O
hTWCZ7se)@UO4Ge3+)E:*6bLef8^+oDJ0R.%'WbH`[/G$O'+cQd*KoOB`E>kZcPOb_:`M\l@
9`=e<dsB/9Q$:pNBhG[9M$-8a`XdI!C&!67C-9CLK@)N0T#8sio)fYLfi3VJ%4lT[M092\7h
OD_^ZJ0>LS[5-Q<u(!08k)@,ZX6CV!<VK>)i"\R)N\=d"2R8^/Yb6)V78H8Eq7`C5V0@O!qu
j!-uj+MomBW%#]A'A)EpjWpI?E$@Caki$6J^lF4:#2!dU'1Hp$Gp-K4Hq*]A\+7BqcI(4PYP%0
W4).@ZIhVcV:k3r\YJ=i'D<NeP4Ne)c=O#?j?InO`=_B(lF'/Kj[AQ+X2Vd*ATaN)\cK>7:-
&kSXS-"SuXO2Lm6/X0@[QIWJB12dYO[5b@(04ru'4leV#`18Cao]AS+n_QqeL9fQH"/$+\40d
M+rJBV*It_c_OL0m-Y4oYECcDh3.<ln#kC#=baA=f3<'t/2ltb7REXK^ElChZYkR?7((Lna;
RNKE[N:nh%@k7drNncW3q2Okb\1?^9&e%TT6d84s#8E'piJPZ8'qSFTusT&.$iQC'i3I)fO-
PKJHY:o[4`^^+\KMhu(<_%<?j4imq)]AjG('Z_Bd%cg3Rpoju(3*0:;?b^FjA6==oa#&@I)Zq
'@)b75Rm;!qfe1oj/QEK5C<X=[K`pQqH&]APS+"BR1)l*oNu?732Ue!L]AFoS#Eln7R,Z<I[#b
I1Ymd#kOehj'5bVS%%L]Agh?aGo]AW#uFs@:RS0A*)4K5aWlB1Zc!_8sT%u!V<i\s,r4kV(TrK
c]A,gk-mWqB!qQi.k8dsF,en&Nd^sSA7,LmRcA2AGrOTd"dA%R6W\Plm8]AG+mEaQ7+2EXRr$@
-i2-S)QK#kdN0e;F\uqeD08AZs")))JEQ2ls(YNI/FC58:;qKI8T_a^$ItKWFbP6=B<Kr\dH
PPgOQq=G)i8AdL8%5'MpTe#\GU]AVH3Q3VU)PWUUe52gk8'kW3hK)[saDbs,TrYB?4uc356uo
bL,$q@Hfd[HkoL6RHX>Khl*0&[Nim?_1VaVo3@UHRd[RH+t@'U+&$UbEamQ\I7WKT=<E*(bK
kJ<ctt+P]A*[JG!B(4+>pNto`eN(:*L'W4o]Ad!YaW2Y')9Tb+cG0KZ"`P'XWKp&2gB6ZQTNnD
*FI=P?g/-Y*9=YD57+hAHlV8GjagTd&:#FjcmOr4MOG5L0i1-k:Qf8>2YQL-e4MG4<0j2e+K
)N,k#1-jB_@)29m?at/N1`n4*?@sF=$&<V-i`bR,hSfG2<W=f(6B?9UBBYPg+\]Allfe]AQDYr
`IW2Qs!.&`%A:e2q[X:FhUqF-E;,+A\fYn6O?L`Brj>B>GP;rR:GMbM_cC2Bc]All]AS/ZBA/I
4hD;)QDj:B`D[>/S.]ASbtP7,AlJtaV4=DgcJ8*Aa?03^8C5IBrUe`]A:7j.bARR-/Qo`MhYDI
q^+"5Ln_@fA<FDR,^i0ab$'"lIGfn;-1$A1O\,Rb"j.P78HO\KWZ[Yl-i*eD>M;p>r?E,=8#
i:eLoc=MWkS:QW>Gd:S%VFkj>/?+FsWlQ5(*K%L/$NF-V2(aS^np@)o]Ar_il#a9.VF%AaPnA
ZCDK3f#;?YG%pMp[SrC_-\QG9%BMT1'2&On5i>ps0()rUG?MeiYbpM9NL27&k4]Akd'R\N?<;
G_%rsk9ii9fHk8tVC"Gs9(#:FBgE2\[jQi%oFt=#l6]A3O+$_7q%/W*J,dBhpqVi#<cVr+l4M
C\22e/m[O*otkmb:Ioo@c-=%_?k,jP'/`#h_j^j_#jhd:]A^(YKPmsY@*sTR`Z9IZK/B1^r!Q
7G<WS<mFPfoPQ:RdjcbO;fpU^-Gcc=RNZ@>W.q4_a=q!L&jd!sM=CB_8s[(=.4rV/K9k,X!I
@<kD5]A-gF:JpuTmA2%]A$JQQ38>CBs,(agM0X5mUZj*pWtNdt&=2bCCl!j<T:U>A8$CAFd1S/
r+6lV8he+8:>4MgIhr&g]A5^KIDi-LVg]AYFL;5tm3uZRhTYeWN8AX.Rbn8E6O2fV`]AC#+d$cm
$Bh9FX>s.!KX`i:;hqe2fHSk;q*5NsdI;1\UISZ$KR7,B4^b<54>7a,)jBU""DjGZkaUHo.7
A%X7m(JM\%)/NtE(uM88kPfp!0XNY1^p#b,gaIc$Glskr&B[/6hu;7]A;r_VZ)coiHd=l5WTs
td$=5L86L0WH80?54"cmK;LmXQ$Mtk1bA)rd"+oukk)QK]Ae(<J[_UV+3=j/Q*&a"E#EcIcnL
iH<:]A2$@Ht`-ZWoJ+^n!#sK;sML1/C^]A>rW&1S"]A8#QH6GO$4a(%R4&eEFJ7X[dlgciB3*o6
Jk&RNl2D6^J37V=?qas7gmYKW(5,6O8@HI-;MqF3lK)\+,;'SLmtR+04h__p?NPmcmN%0`Jb
Mf85<1Jtiu#%h$7R5Q"8tr8d!##*/1U:/V3iOVa#kJnKRf)NaP$_HZs*+t4)h.<>+&+b!1N$
/TQH]A7TJ3JGmh__]A2?E"!KUer@q?r9"!Ab-Ag)g\a'3?k]A:hl3GUs)>ebKd2=l,s7K1b;L--
-^j;<7:1tD1;)'B';UL&*)#n_o(k2[&%]A1=(TcqI>NghCh?-.[Qc<X5CH`q.Ral+($CYhf#G
5mI68A2>MI)L%XK<\F)8FX(m9Fq]AI0$PP=Ul[G;:R=;XQ"8@?K;6NSE5;<*sqZPU8A2R\*Q1
"PCo`.EkIT?d>qYqW~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FileAttrErrorMarker-Refresh class="com.fr.base.io.FileAttrErrorMarker" plugin-version="1.5.4" oriClass="com.fr.plugin.reportRefresh.ReportExtraRefreshAttr" pluginID="com.fr.plugin.reportRefresh.v11">
<Refresh customClass="false" interval="0.0" state="0"/>
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
<![CDATA[1485900,723900,723900,304800,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[1440000,4032000,1440000,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0" cs="3" s="0">
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
<C c="0" r="1">
<PrivilegeControl/>
<Expand/>
</C>
<C c="1" r="1" s="1">
<O>
<![CDATA[本月累计销售额]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="2" r="1">
<PrivilegeControl/>
<Expand/>
</C>
<C c="0" r="4">
<PrivilegeControl/>
<Expand/>
</C>
<C c="1" r="4">
<PrivilegeControl/>
<Expand/>
</C>
<C c="2" r="4">
<PrivilegeControl/>
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
<StyleList>
<Style horizontal_alignment="0" imageLayout="1">
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="4">
<![CDATA[#,##0.00]]></Format>
<FRFont name="微软雅黑" style="1" size="104">
<foreground>
<FineColor color="-9302" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
<Style horizontal_alignment="0" imageLayout="1">
<FRFont name="微软雅黑" style="0" size="96">
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
<![CDATA[m94@/db2(<;eMPrRV&jnZ:UUa8BnWfdM1(hAN?GUAnJbY^+d9f-Aip&do9h@<^r5r:mTgnM$
e!T_N^o@$7W]A@5c$ds8:mLj^dXa'F.RG;h#$3gHU%;m^\?Hs[=;uZ[F\UZH2cJeID+3\[eV^
(,GVZ%J+,R4AFt(rOjW`M:HpSXj=\K@)Au]A83:-I%iu(8u5(\q7*VSIIqH]A(LY<PB:c'\?,n
ACMFS(liO:i8+mflQuQM3rlaQq;7@^c.i%=P'F59A0-"fDA(h>HT^`D@l/A^;>,>rO6+"N.6
<Oe#.(=70g2o8JDZ:W9JLr&;:8nF\j?H-&AaD&Yo2['_;Z17<Mhldh$#Y_YL_G5":lKf.FUT
E;7_q@$?d]AhPL8K=W:rSLqn5pp%`:T?,o>W`f@VtO$pdDWX:%\:I8XYT_^d>Wf'#,UfUnD7C
eZ@g^.ZM8B\BZ"8dmgot7"r;Fq^*J]AHhI'PmsK8e's)hcS,r[@#1/&XP]AOoi;-bAJ#&-L7`o
A9QkYS[8'DkF(o;0ZG9d.EC;BRmo4pAi#/>$/c[cHO+u6%M9EO,)hkI/`!oN8643YK@0=g`V
f?&GSF'Yri?csV=`VI;Y"E'n$0W?6(L%]A<OfHko++%I'?\K:,"K\$'M5S7647a%\ElZXj,R,
80!_d-7P128s("O,eHFLN5qW:,Q?MnjMBA[T1XlJO%DRh(kLB_$EWH<_L)m%LDnB1R%ciUtW
o;s_j4gE*3"TircYGY&k&9S_Qab!gX"sOOa0KK"7b"73m!pY)I^#]Aq=6<2(km^5l"!Ldu6n9
q&P&)$oF<Rs-b8bY.JdVG"CId7HOS/Qn]A@,)h#;Pi-,-aX5J^q!Khr@j:,\()^ufpdAAPabi
$ePq,5e<k[+)4ur9C#?h<<Lra[74:\MW`9UkkbD?*@VZ!,qjdO.&a-nJ[eDA/1<8Wr[f^E6Z
nl9909L_ST,tDQ)Ou$o1AML$CU2kA9^CX8jDN]A`g1qXW<5+Sdah^!/7%[(+q1I1RgcVEdhH[
Y\Sd/Aj\d@D'VdRg`MqSP:dSUmp/^"dQ#>JA2IhD11'5%Cm-`<MV/E$Ss!`D1XT`?rNK3(AF
r-jaB4MBID@!;M^E20[,E>3ZX*[-d<e3("[K8`V"(F-@f?=!R(>01I5FusLnp=GM0pW1j=W?
T#489?I91UVDYq$=8a5LEahNBLW0g9$6GB[M!GU+A;u'7:_8,D/m3\]AR0]A=+\;QEBg>u9c9[
M6t$A/./V&,Tj4HAMYGIB1m:o=#'FHO8l0OohbZ]Ae5/1=<;\jLWLg*j4Rn@N-f([nQkBI6@B
@(GaX.nsQEXF[1/FJL%1Di^G8`RA4#t)d%9]AYH%b32[pFDHqLL[W`rXIrq,TQVf0?hXQf=W2
m^CFY(RcfI!rKnn3Xdn<UL8S_8h]A;O-pGN]AO=\lWLql#6Tu]Au/X7IieI0;4d-M;j/>7$?<.R
5<S8\fHkX=#ue)b>BaAt6e<2G\tl\^O`L<'S:(>>qD4$KGk,eUcFY#nR(<Ia%tDZ4'`iojk$
`k]A5aWoY4g\kC@s?MVJRNdbjo!JkiB+7sMRj.*dA^aT4AL^sRMT!m;DaDo$JKBU7?]A.pG*$R
1n1DTMj*fp8jX7efaqL\?5Bgro)OkRM-l8@D1Cs<'PK-BOda<eE5kBEpcJK8>f<D^LU17?6a
>bo>1(i$?+nKH*UV>\7afK0Do6hpNa_!GJo^]A%8\p<l0JHqq[+'oinASHe`SC)DkA$V<d9b*
TgHs@4]ANM=nq<_[r8@[i'aK:n3N_5PJQLa8:eW>2e9@KV.<mHH!:&A+GIoWe%hrS8]Ac:;X:V
4<<0?GbZnW%6DMQ^9aK8ZYG6\oQkNsphp?ef'qJ!an2-"k6Q@<qFpcfU/d0"ls>+&HRd2Qmq
BO4ZiO`PWoN\D9;_M_f?7gWWc_l%k06iOl`k$>*_4m7ec'ld-3cWsq#^$DT/,suZSX-f%ac1
&T?F/d=$L3FDGI9kFFBa\kdbq^kgm<?R7Z\8-FB7!,qu]AmL@2l+/)!5gYBJqQ=Wh'CP0TP8K
(.W/$R`%lA+V=MGiU7MWTbQ>lhAo7&M;SZ5)CRo[WD#,>$X3YD(d``kG0=[\lUNQqD,`$EP\
#=GSgqFkAW9hQsMiEb.Ec%kd>O_G9+g4JiFP4N<r&$R9.hl27c-eQnA*@_=p_31]A&3/YT[`j
?EYZ5Muh*;dXGXZ#!)'TeE_K>O8WB:BdjouGVRW^M-?:$el#"%n_n\DEl^V:iR(>[1]AKit:L
H+HqG@#n@7e.:iuplaG%PK48g'in9sLdlP;Yh-if@?s!Wd2PmJVtm"+65H:@YMfKQ)Xs$.e$
>]A6b8"D9qC`R=gI$/2R=:<i_'2VA#p0qj`(!kt4Xr+5pRQO<KMfp`e?!0QVJT*)aBIhQb;R4
0]Ak*bb*@fh:>>gnGVGkW<Q"A]A:/GpBh3[8]AW@),h`kWK-r_"79"&ekXFuGWiK'[N[0D]AbP`/
qnKJ:d2GbBP/d?j?H4#*Y]AB/B&UTmh.I\36OcE-D6Y7:49)QU>657K=er\">lQQK.PB"<.@s
omfr?=cV^HlUqZ4c<I63X5aXAK3<HU^.[E/^oBnR.?b$VGWM?EfN9k4H#*%h3TBPXhk_"tl&
'5$e>1[gZrDoao+2-1]A!p(Ljs5V+Pik`,rO-o5XCgeO/"6_Mh"Boa<6&8?Oh.?7JDT[eUXX#
if3QY&o>7fU%V-?90Y*2doHSDEAnS1t7aWE:J1.V/DR4#!$l2R<[-VL`=?.d%o.]A48]Ae0[W+
\7AB[(,)^,sj;WD#7:.6oTPBi[=mbRg1"]A&7AkJ2'NCikpSr/PD.;=^_po:oL`i?%_e=43Mr
IO9')Bc6R.=(RZ-(8YT*4$(<;Np^:SBS9e71f#]A\Dn%l+N)\)Ltu+1a6:#GsC@cga_9rjL^4
Xrqf+gHEd?QujDJ?GVI7iJL7%[uQ=^@p!X7`eS)'^RDSlEA*B1j_V9[Q<1Q)NW#ffc^U'U:9
s$q("L`"%^(Z\I=&TO%>"T(F#>95#f7$;p[B?geOB3k45#4"UfO4'[j9$U,8PlNF44fL6;&8
oGpR#n=@YICofW4NjUE'Y(`2R&]AbC7N(La?hMItFXo5=(9CBI>uX0NBS`QkRXL+Y-M*`$1MO
=Sd^D_rG26<f;.#B,U/>/uD2'q,3&OGQQ<I5,6n052=Q9KUa4)79E[(:qO"dg/f2HSbPpduU
hHEt'fG^.4=2eF&7Y.`sdI+utH[%uh`J"To)-WCDOs2RB$Y^IX@$"[X]A3pRQO8*)DO<9X.g8
G5b)9o4(TSpMC&[mDH:G#i;Xl/t:Z,W!7q4-MOkX->bmF2_IhiQ:suokGO1UUZt!X4_36bJ2
gAB_$P=cTcfd:^WLd=n;)$4?%8B(Yo1"L;Tb%h5*G*3HTJT6kYfh5V;K/Mj$IUNTIBJLTa'G
%Lf&$DY2)G%VTE8k3T[Wq7EdgV5t22KUN)"e7]AV;/o[1rC8jZq3T.;Ubh/QSE)U;uIC=VC\-
@C7t3V&6JJ@h,VmYA&-aSETUB7+P[.%7S.FDH_VA'79nq?"%l^glU'm?IimXuV\HK>3WQm0Y
B/4l3-66?H=EmHAe9cP.coFh"c2PGRIj4/4%T&%T\:$:Fs^W#6'J"Xh\RcE+:TO'l$G+>k-J
E$>/r/ggKR9A^o([lY%PIeMOZG9_B*im"u/_lkHA/Z*f_B+2t0QP(VoBp]AV<>.nJh@"hXq"Y
DIFDlW&>*:9DnI7DI6FY6H?]AL'W&Kju\iYs6*d5G%ZP)6@S>fNRgO:)f6Ad6EHLFZ=%p2=tr
.g8fZ+P&6r/m`L@=\aGc?OAmfq9BAWs(=A3cql'X)]A\J9>+nq5C5MWdNnZd:_2Dd5_'D7UE2
LBC-;;"$,?B[cN)\>HaC&:XkrlB&"G!`g/3+Of2GKcn&6JNn,BY?<![@F8erZ:r,e&!h$^\j
T!aN]AY/4V*%5q`k'j.+:pJLa2d+h=L%B<ChRrcglbkLpO1\\_j?)I@@t6ZuRMh>T_a]AP$@np
U8o!m&8=OGmVtNnq:;BaYq-m2KMhn6Y2rh/*a:`$Hn89p9`\`Kn7_H0,9#aNkg-_(MDVuHp#
YIRs4/I_O$IQ5'T$ne._e5F(;32:$C;pZeoj*U>r8H=WlSsOf2Nn``h:NM$MDBWp+j9\HXka
:o]AEn:_@Y+$&'hX)m*oq5@,:ReDl`U%DL6+Ha!+Q:JEr+11SXPL*rTl(Z^Z2UGF:N6Hp#4r1
po>)1"6Ys;]AJdJ*PpIUc0*%RZdL!6,RPrb/45TO1B1l@1?UtI=;;ASCPh6d*?=`sh,BYt[5f
#!.3up'`ka,5*c6EJa2;3f/>%(blPpa67@jd-ZQB\g2#^ZjkiifrMiuqLN%A58U&EOZdFeIm
%eXqoNF@JfiC5n:BQWAU(<o^;9!SHG9!m=H<ee&pP;63rj(k-SCteS"0Y^\$kJa@Fme\.ioq
2de9^i9s_`.d'oh)lnR\cGbqe#"?=7O>Bj&^^)B?8#112#S9ij!CVa&%ji.2'0j`>Gm9h$j@
r;t2Qt_NFf5WceXB7I_L-?aYu;mNc)qqFT)ch!?"9nZo4O_UM>uF,pPd@(L>dE8-QG6<\OcG
P/gaO6\8:Gsc(Z5SHj20?]AC;CW0ui?XJB,`Z+SP,ZW#EZ.R=]AcPB=fBnH4,NMKZ'MWQ4TAu'
8eApm/aqP(3F:q@4@=%Pk,]AJ>t4GJh3:IHQ9HDFl.4@M'>!k+`Er_(N>OdWh:g$.(=I&*`8=
gH'O)g,pg'G=c=<,-%1a5(Le]A<9D3;GbIMcp^"gfT7e@q,;$&Z9.JVqE4;.P34EL7^dS0aMp
iOPZ=ANtO#$+u2>E42J8bs3(Ek]AbMI_^64sCAKCF2-d>(iP3^hl23A=n6+:EoKuWZ!18!$/g
uZL"0Na+>4$bVp#>PmRJ[W^`;XEq]Ai%hjRO)aaf`"3h-J`*C5=<V&f3r-QRc>2,2E&k_5%Ir
^`*Xb1VKLo^1u54;fSXo!3#6#BOqfaU<rPWXVc?c`Q>F%LMpE4@5"R^H.e_"Q"73eQ#S`VJ.
GHr[-CY#`9<s7D,-N^Hg_8KJ*chmA?K6$GDh9=468#>F>6b\,=hnEm".;?``COD.A^#%$sR-
8=kDIacer>3"8:;&UT55+!kSe,"g/VU;FfNQk^!^L(7M8,B^L48UG16[Xn>O3J5=J)epKl:U
?Y=1&,?I2fW)G>$W]ALW[;nDh[[P<K2`ZVTeg)N1<Z4/:Jd4Oe'hh+[-s7N^ahWp)4;MOnpG-
ief'.8=WsXsUWt_(=jmaeJQ"bdHS7.e98<kX[FJfdZ;OQu6,HSR1lKj@h<F-%6#%qS7IrK]A$
d&[JS`2>@Y*q0%.A'\#d9LkC/$hN^Y09C%O3&ggU<3]A_\c4)7=:G<E[?7I!'.,5SL;H--9dl
dd1@)BJ3(L0A0DGouh[i')4)&u;?&HI\'Yl%65dR(EQ/)iC&[f677N<jIJDK%.2(-6KS#h,S
;iZ(0EHPPYk)O,Ak-MmJMNjc!Y5Kpr>7iEWkN(ZsIi6H,eZ[]A5eSbR<%X8Qh5GL&jP`):AJ`
9C?8eod[f-1N*Q5Do$nc78!kq29AU$T[D:S>E(-F>\T5a7<6'_?\VRpN9`.G!:C#`7)8Z[aW
icr\*m[HfHsTR5[inM)pJQC3g/?MElo#s*a^MBu^PXh;,UKg::>FmCu]ASIq8pLC:Y)'ZCGO+
+YHRrF@b#XHK+KQ%B_A0+-V6V0"XO5rM]A(VY2MP+rD*4Si6$o`39asQ$e*D#3hq'$V2f%XSo
K>AQKaFA>"GS\XJ`]AN]AMjRh]A<kf7i'Jq^^=I]A+2+mCo0;]A]AMN\`I(D;L.a-pib\sP69pOp>:
0R[)94;toi;,?!kZA!ViNcCuXP*D>rlp5jqf#hkX9;\,(UlJ_99(ELof6nr'I95MiEc/^q8,
)k^s138LGQ$t<.IB6,NPh5CkBmo"[!R*_b-U\UL/<B^(IP;tnlV@s\hH*M]AR=qYJ"OBhR&IK
Ki+Q?As#g?eI9%$Yn=tom"+m-CT5IS@\a$YkFFDo\Z;V4*bF?d`hRCCZp$\Rd=1m@dOKUNK>
W/J5FQRe2GBX8brVuE-^MfTk#r0Q__Q8ks7)WOfC\02jZ0sIEAc:W#pqkG<m>Hf;]AU1L7p4$
o-^UIHai/Bi'/9[LPpQiTfi$Ik*GR;"c?32d2QbZ8P-1DOl$+pCI!\]A-)pV7mC]AW)'lC]A:#g
d(JjqZ`(linb3*[nct)q/+XOArXSq+Ce;,^>S8XqQ\9hqGLi;OMR)H:C0DGp53V<8Z2`>"rr
E~
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
<BoundsAttr x="0" y="0" width="114" height="72"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="161" y="7" width="114" height="72"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="report20"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
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
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report20"/>
<WidgetID widgetID="06bae1b9-86d5-43d0-8389-21d71a3ea643"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-16636871" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__81564603BBD4F6BE6C196F5CB7615F86">
<IM>
<![CDATA[Uq9QEAPq%_)V_]A;-R\33Fum'S@N-?B7`SQ%=<5"`VdnJmrVa;\p[)!u<inN#bu%u13Td?q5?
*lCOV%j1^qdaIAS!.:rnU*ES\O)jr`t$MPSet&GsoeILh_1rT)6Fj?nFT+1(ckW>MpiO@#=m
&p`0n4>Q2!`NJ<H'N@c;fhq4M\KP/:>TjrC$'rl"\^b:1+2T9,fG4d/'QcId<a@N#5P\`O)f
/5@p\X<VIb'i"5S^%m^L*FZPN07^,7?>h6UA4ce3%lW]A,76/9iUT=8ql(c_b=Z>-P_(Wd#Mu
/0ZZddoI84_HLIGN0*^c#_$E%M$a5OJn;1,`3P3DT7qsTHL68@GkWMWX0d_e!]A)qEFeY>V0I
B-MZtl_iVF$/.L3an)!]AUpjfAn&:@FU-ng,j2LKR(5Dp$j`9;DFg3L-Yf]AmC1&(Y]Al9.HT@;
q8q-/b-pld1<na.R.jW6:,i@o:WTCFV)-h:TpaY87X;AXefW!U,,Zjk-N++Z'grk=]Afn\ST;
W+KUc!6[l_\N2MEA%6B5K.qfUuZP1X+OR0kS_,-$>A]AN>NNGV0%:=dg%l["mEj,r=B;f+E.a
FJ`+r>UQ.a=Y`CGo)*06)9BaB?desWhp`)J@L96<]AT-DQ]A+bRO*s8o+OS4HN`gcJ,+]A2_&9"
?0A"rO*a@N:^9;=(u2E'"`Cp5#`FkUjK-`>s%f1..J#JqX1Puf6c.WNhaSedG"9@.<b@.*Cs
d3b6-N*,)]A7KJtgs+G)R"InSreU3u5EGqDD+h&X/<CI@dc/Ucr9JZTijJS-WjRP'nmOJ\PHP
5kbQAgQ(:k??a*eP!<RhU!)m1T(2Db1+MPF:q`Kdi$KboenFP";mrQBf["=`l7WjgeOK!FA,
e"*oD(\W*:Bb`[?)U@tK5HtBN'ps9&AqGJ?Q@Y\eXl4-qt>8IK5bp6R/Yp=S'Jss:Wkh$`(;
J)Dn$$UnM@0,CNAqK[<#-:d5h&6@"KSJF#kb7jBABaDr'EV=cb;r9W124mU`P//Qr.SbqP+3
8_>IH#($S+kDMnPR\XlkN!Nj7C%5sjPBGF5g@82I9c5mP%,7N!"g#Y-Tj.8^=.>DV%,&gTIg
2KWJ=9YhY3(.Kp'+&"Kobp(]AV0,U;]AFO;o'8imd,e!M)<U:6eLe#KpDJj1Xt#V(<b$h?^(\C
ea1O;B*aQR\^dE3WV@Sg+Dg:_$!M$h'8u[%cHm.]A<F,P4#Zn[3>Ck2f%tA_WFIa%I!Lp@A]Af
".e]AAn<FHC(cBaZ&9`9(':M$Hheme'a1enmH_C#%3?Rn?a2T:h61<&'gq/V?"`#g_<h/6dEL
e2EML*K'6aDD]AK$$Z?q<1P8+M&]ACHBJ[c9KS.9-0F:oU4$FffntQQbU^9d36J6iQPKig#QH$
<)-V7h0p<W+bK:ZtFaCSpuR,T83graB[Paa/n8I$YbM2NE:ea'0n>30;E_`Y/?-rt:C,h87F
.$6T-8WaoQ-?(mF[W^+4GEUAJUfC_@_9CDLq%k$]AdoI5En:!m,.mAP`5OQCFlJni&-f;83_c
ep?N8[+ZN2="/C)%LSe1PUJ6.=$fiaF3W'F2_]ACuDl>^9J%jobmTC[)V?.O.EUj4%$\4Zs9F
GL\K4oCNbA[\sH%^^6Rj0c'Cldhq+%)`K9uTAYa]AqfFp<t>i%g'k\_!c.m#O;GS8#AC.fV0q
,bagoX#O;YY1Ws_DQMhiZ^6Qm#i*"c6pZMU%iOEfNXDCI7Sr[\PFZEN<YkAiC'?]AUsuLU@:;
9)!r#9+%H4"NLcg'q=]Ag9o-.A&c+P^-Z3j[0"e0InK<CS0^D-Sos$JB6/^?m%WGlkpO*PS<]A
A3'&c_)'!aYq&3V)C3.!bXqOgJ.6`;;U@<0(7c?m24)pV`*khI=5Pj**P]Aq[:!ui"[rU"r>!
OO]A'r/f)aI;Mdqt)XI3:j)8fZnD7j@5M%"#TX'%<W&]Aa:&tqh=;f]A%`H[Q[NJomLp$:^9>fC
_4!D]A!KGiK*K5rJeNTlBXnVVrfKu8!@>%#rc3tjU#$5Q!/%C#blOb?f&20Xkafckml'l$BPM
cXkQW.Ud(F`p.8Tc@,g?dkCLH[ui;PomG;LJ^pT0:amY"1ZJhW\-Zh,m3uoU%Y5&0m83_=k8
L0(X>l[<s7&keCF69`ATAaMF[dh7'4JV3jWJ\$!oFHB#?Wnj9`2W8rUGSTT=oGhu3[s-X-7U
oI]A72I5A?G'g$o_Jpf*YPTR>o65b?Xk*8<HM05qC`h'@Qm,T&_TpQ?&!sCBbGZJ\nrb'c6ht
:>_pR`C5)T'BBN?QnM06T\WfgY*KY:=%edF4-2GHshdRXA1)\Yqj/-BZ[["[.prCg=pP2:/K
"L+OB$3*Ta).qQ?QqF?UlYu/GJQK6Ci7_11gr/tcq(;th-S4LE:[jEg#EA)73FD/Vs.^,/XF
.I)6,2hf5bm)OTdr=b_pFI6OpkZ;O%36jnh'i)4?Nd-^>$\A\m8:#%A<2g%3%pT^dT<S\)qY
*=:F;MffKj+Pq&V]A^Ni/G\f3&iUqf9gZMt[(ZWB@SDb/!1JVhH%5!>3L5<_!>Z!BZ60OK"Lu
8VWC(\)lRVV^<=3;>'/dh*1?Gq7\f/I`I<5a"=L^M`N9<e4qBFDKZM.B<<?]A)`9q*8uS:Kfi
do8OSn9LDQf]A8fWHimN-#P:OkGuIGApRK'iCc#$m7gpr\Wr9qH?=&NqKsJa)=D*fO0raS$$$
1Hrh55U3+7!D?$GV]A3_0Y3EG^id)C?H.2q`'8o-"V:D.'tLj]AsJ1(]A(c*#Yu,-N8Z)ZubK-_
b^'p\c[g<f5_^Oh;c6KmPT^09!\c7T?-TjgOEc.pL@1\Zru]AAQ62o5L*aHflnGnon)^p%E)O
VQD32;S(u(9.cUZ4?>+`o+oHNBsWkZ?Mdb"jf0;A=4(;hDH;Jr)A1Bd1;q1937VO-S(J-_BB
IJ7`e@JCTtAJ+\[cf4es%&sq*3I9J*'X+!%%g>DboZh-ahh!#TN6GN7]AHb$@.tc.GHW<Q7!j
;317Zo;%H_QC'4A4UF+muNJ[6/,8FO=rdQ.3$UP#n'&DXNPkgY6Y3hJY>L?[h)Kk+3>:7(=9
*:PM_*r]Ak,B/'(Bl6"bS+Fpa:aMr[^)5\tj8he"XEj0F%1Ag=4%!hu:1os6GJO9/S.?Q-5:T
3&o-f5'2*!7=7!1TpVQHi9CrhaWdP%F[A0p>Y18JZ1(X##"q^2G?80F/&VEj.ZFWr.lY;V2e
ok9hq9GSdSJ`Tgd=M\8-ZD+K+J;/9,feN7\V_+Bk"bkC%,`/pOqU!T(F)H"?Zs&Q+tUp&U`E
L9fLjBDRC]AM7UL2J)O^Dr-A#qFa"J]A6`oV5Dm$k[k$tib[K&FS*bEcLXCaKYc<e#<Snd?aOT
+r18,]AV2gt=#-l<:+nNVh&6M/]AYa$Nta#m0E.`214pNY.YlHI1L5>*,uAUI7o0`I]Aj(Y?m;K
Z.PCK>_VW^r,EtmH)#aI%/UEKmXbAbDnsJ]A":9?Xe\NuJPi>O6KKMC't@D2,hA>[rldDO4oh
3+[170#5n("$86."0*jOGm]A5[3k.]ACaRKa\((G6pWdh.`DZ_9^[0\&/"Btpnp*^s]A@BudTl0
D,K1B$^*CY3l09+"JZ*j8^(gt8#^J@$<3f]A2#N9OtP[uSe7VPab`\!Eb#rdM\2$eIs&?+=KC
X)5kg:L*ZG:-RP\c:gk>Kb802$1e':=7Z6_\:43?1Qgkrg`_/_RFY%!m-uDnj@e'KrLl`[T@
!%ga(]A$5KI]AOM\$)egUqFpD\mn'Xf".,J,7n'(-O3&XbVTEBj<f.]AN@1f=\9W!WpASlj-c=!
G(5&9V9A0Y!^b9qCUSXVGZQZXPf6=a.)idiFGKrP[<o<M(%E^t,/:aYLp.((cAfY7.9-?%+M
><6j?K`)QN(B-r$mi<jJfHIh.O0tHr3EJi._WY"`.-57>ZK=GpWi`1op2pW64sic#^]A2BWZA
'GbpmLYZ9CC:hjD&Z"tIT9Bc\q+qX7kg>FdRQHqF(faXr11N+SBBg00&MpF]Aa$T.b$#F/_*Z
5$0p#(tRTR4M?'9emf4%:l^MO20m<j]Ap2s5(hY]ASW9i;<TfGP_s2"/2IqccB>SAL`Y+9UB']A
NXqUlHXC!la:r#[\c#c!GI^[/+Uj't77OC4RbP=ofCYfkB[)B"EQ"V&/6ta,(j>O4DE)mCi9
#Z+)1nSQY?:h7RjTA5^1=3Nf``3W?_&)G(+/,%tRtYn3n$?IPRT"=q9d(o+QEa*TOIX=S5e%
XYDHd')SS6J?-1eL3GAShs0]A5rCEl1Vki\2`En0K6Z&#Hn##7l70b#YOr7k[ESI41AjW`qDg
?q]AIYsmo!=[gpBmbNnmD)_X.,3(&\f*Im;^bEBA0DSi,AE))UYVc@Y,dj`9nk;,i(0$`;kpE
i.s-G+:mipV8)g/*tLh-*,@--=XT!tKWbk=O,H:6DdU0.Dk:<2A;+A`+(*2dGO9rW0=PTJ1c
^WQa5&XCTl[F:a:X(g[VS"<mD7&>eOQfUO$(J@DT`jS4.l>Y6/&MT:H_A*%8T_LT;6pChjuK
*4oXTm9SFA.E+*ts=k9dVf!j=mpb/MH1SjHHA(1I$Qo]A:nhl"E:G,IbY4!<T\D6GWtE4>^0%
1ode+3G\0\/Qm14o,L2,uq>eE=/#TRZ%B2?DL"BVI]A/gaeB5.UTpK?qcF2Sg-/!9i2Uj;/RM
0s`p':]AcbQuPVBo:BZ<,'qL*\.CB4Tjo/KneGc0Vn3:"(#jj<m#i%n1q'I,);_q!rEN5AZm;
X\[_KG$D\^>?4qTXTdBMQb?F*:fk3/8#MgG*\jsJ,qio%FgiS9WIM[f0Uu9S%VKJ)PKS'q@p
IB$m$rph<eXiQ0C?"biJce40W_3[I0o03)0'MA^-F:H>T@\3S+*Oa;$/oN$M6:=0lL>Q3bs=
-`cI4$-\_!(>qrZU*kR@Dg8=aN::Y-JlX3^[)F#BTX!@<\bq28BQ(d@mn4N9T?I*J0qCp#X5
n<Y/NG@Gt(dC71R]AT3D"#g]A=Q>GA$$rDkR*;Aim:U09pm-6MO<6QECh^6hE``';DFMXoq"1D
QiWI9NfpZ\*TF_3WU-e+YZ)%O]A&h'^\&o7I7XG-n1gm?m^>6%>XESQ_`+X*EE$&1[#^!2h(P
6#CjS0+q=Kd1,QWh5R+e+fL%5'oViKf0ZCrPsR6FP`E82REnohgj@l*Ik5Pnb9e@U_oVK!'9
jhD$8Ic6\FuoTcb)[f0sofl#i`^WQ!9S.*Db-&mauq(gB\QrVCY+R"N.?KgEGKG'D0/bC3ts
B=o,3^rU0KBiHY&bfB%C7*BWO@h@:[WIPE>lpQFU'M7K]AWM!;dAXj(d.N`Z!NHu#n:h3cKUe
]Agr!/>l)&JML5_JLsm.@f$<MECJ?@!J]A'PB;Hk0h,X?5clEHDd;E+6N*@55n7ggiWn$13\jd
D;SX%UY[V'2l@2C`2N9q#4+>KA9%Z$H,1f%0"RU)g-S[GJW_^E'u]A8oL5+U\C_]A]A3*P'8TBb
,(/+kaAGu3/)ba:SRc1YNLj]AcV=k_W:!pa`mR:NB<a$'q52?*8H9c_EFX[/)IQJ4$/$7Rqc`
br@Qqkfe[``Br'S7CS+BL7rc,i)>)r"f\W7F0KLTH'>"6ij.9_u=89iOR7fUXDZN$plR(5*)
^:bT:LeXQ[PTM\G>g:95MDpV]A'B>p=?;o^AWbN<=_(:Z^:j37A2%)(5\aG!5;VAAq-9DN^gg
(*\!pV*QL1"H&2!k*R[0BDXL-uMY41m60Zi!8YGNK^.Ui[Q@eV)IOn!%/):]Aj+a7Y#*R6_3o
0ocn6tl8_)?0))_Di(ndMYf`g\PGaMUo"&/V&43;G5$E2\m`H]A\1e.8_2/kGDp_)H?FB'[mV
/8$!?H0U7hBF0#Fp6be'QmS!f8G1nel_,(`=e_;4i!o8W]AR$T/-WQ`np*f"4!Bshb-KlV^X_
(Q,^R]A9Z$]A"$VcuHFiT?jJ\.Fg$cUuo7E#6%ahiODPL!FMDB4=?O[ULuG@f]AE;hqM.#2Lh1k
XAMNrY:s)$tR)"U3#iR",[-%a."&%2A3o!13aRKHYp?<JO&p=NnNonZ9D\qH+9L[O_!`MuaW
<bl[&>9D7C.rd@@M!$l;*NfK['>La^>iC80&m%=7J3>\6rIIb,>:eXYJ19fE[]AA_741p(!6O
E:fu,]Aa7'D'F"aW,!GEl_oD^1E,]A0r1(+6Wdp["C?+As-$ao'*oOJsi]A26gLeZfLt4Sj^CR!
P"53ebSAWg(8!c;S^E=e34e#N8Q-fqQ>ioW*,SMbm1;QBR4sYjkV4*bZcS790O^HXZ-k;^rp
?l%C+AbZD9(^f`+T;g2E[CDPkf?[jS'oSON,.b:M%B0i9HSVNijQ\R:+Y`.gB11;"VSBM+&i
b%5=nd%R+G]A(!-[qZ6`!aR'>TQ9dYHm-LM@_L2eQ9LXO1EU[+*W@d>mo\mC$.(:$G`MD=\dR
<7%2)Vd5\8ES2++/01Yg;PCGQ_R(uSoo@p)fDftlsDhEU>rs1G<B$5dqbL@p@=htZCdhf+&k
pE+`[Z"Z1hZ;DUB>3%Oh>5(82#b.!r*o@UcGTG8<ZYAbAW,29\>RX7/dW[k4j,)t7(,.s!\N
-CKdZUW696Ed[:URK[j]A7J#/+UrRsRoQ!-"-VMO7%.$XEm#FOrYNG-##bD#l!=tS/PteEk7u
WW<Q)U^nh]AZC);W4B]A,\?DbpNkL8'<*X(qbn[I'o,ACR%GBPs)RYKLG4iOV1rU[S@Bf9M"Hm
NK8ES1!/oLIJThtLA#q^D7`'ao,Z-4>aiicOkUm1o35\'K1U[Ou6X(G,HE-I,lMn)kJVp@$7
b%B3L>0[YjPd%7GMZ=c"9QPe_s%N31%/Bg8KJ9?D@aZX&9i2Fci2$'BH9=Q*S)3oY,Tj,dPi
Rmi7fgr>?IZV$(CDK_oXJh,T0Ete%n[EfKWp&)\WleZR9%CWk,F&pG;"^;FWq,m0q=0s4h#a
7gJF3$/3T]An+[N8;[J>^;frOi(fQEjga:CI)"k,fc)7tZ>'DS^9&p-/Y'lO"/cUg4JqEEAgg
b?\N$&-I;A,_'Z64=#iA$.li?H)a%b.64c122c-;kmA#JhJNp>YcLU@X@Q+AI9V<Jr!Y6J+B
INuEr`<_3CV:Y6\DAUOBaHjj_/M:@q"M:B@g@7Tt?i5c5P/6(XE^qeY+@Y")I4$45Mpn-b'%
G1ab&GS`U?1f/??@bPJ]ALGYrncfZ88)frJ:`qLj0P:hnB&(DT@))YVl!*d!pI%*&EDnn"%*4
UTA0br%rl)plh_n4WePj9G3nH-:S:14"0IqFPYYr#=Oel<8P['(Wp*Kh7VH]AJCIm1^h?=lCd
qj$DY98j+aE28G9#o(!LD_m-;O<lVPqG/dtn'n!KlVb-53`;75PfJ1S=NL-SI7:p.H!UZb)4
M</a`Y+UOcaY)o@#RRpc*"f:3QSBSF9O%kNGuq.LX5;J6\*%8&$jr)AaDcGr,d6)\$r2Dt2?
ABi3F^[g0Z8/F+'=1sr)0JA+K]A:4Irf$;^,+$epP0Q1G1:![.fm4GD;Qpjr+M=.D_;bWUKmS
K<Hqmk6?3St^m,n6h;QlDZLG&u`^kHGjY/UcgR%2D0"a9oKl`]AbHWi;BD.5(A\u'>lHIG89)
r&,MOM9Kj<dR6&7&0HCQ):ReSe5&f:MgF/Al/+4jKf:VO,YjGYF^U"GBUBp&5Ilk]AKkJLmUg
LR'b*q?+ru&_\uPWE.:id.N5&o^t9R3+4BM&)IHPOG=TlDrF3\c^G9p%ECUM`Y.'8#h\a@Li
T?kLI[FR5^KX'IIQ!smL[>'?$q(3$UB,>a@MYs9gU"Xbu:=)n9F1E,e3'SPVZb`>"#B^nNdX
i74JkZU)9H("^A(^CeN,I"BrQ#(WJ/*6eL%rZ=RPKUE^h]Al<iEtip'aqG+a/$O33iYhcZX]AH
hgaGEi4k#X^D'**gVX+$">0jpg0&i>;FRijBjJ,(.J2K-89,nEl"$5J(bIpn3(.E;u6[#C%-
,VKTNp:<Sf[1[@siL&b46l=gg?$^:>o.*/E\cNYM,/(1'_!W_qkEW_r#qF&M6ihGS21Kt'm8
n!1;s-\.-jJrVbE<b@M51UY>"nC;2IYeNO5f`Cldfd/@b]AY3M"?13AFTUFaUTWhCd;&ReF&=
K1Od_WuI$pGM$ofj;XIm%S!?UD?VJNp)=\rm7.$E)]A(H,Do##*Jg]A*OcBkN,-3<aq3gY:^bp
XLC,g7E7[JS7!;'EOj=CE'Gfae*(6k9?QQL/,Mmr1/(K-QIW;P4n1i1glnB[>J<[7qJR=UY9
loBDk93QQ4^pspcSD61DJ6i,rCN)TL/_dcjo[32p8Ur<*s6*ts!s?)(K=$L2jsLBGD!s:24N
"/i\sC5/+6b2\jKAaK6ee.=oFhtq821`K%lc:["V4cmcr'8?k;/Ta<Z(dPMM8taSrXEPH=uT
:O0[@UYqAb=h]Au^TOo(gPbLC>W/]AN4lV/#aJY2;6.^dWsQ<XZ:RLBH/7gAI+,bgf!Hbk>mV?
+-ORd,IJPjAEH#EoKQ?CD*Z?:NETSf;4AZie;Lmd<1drX/qT`=S2.,ULuu0)6ZMCI$gLH3_"
mIMOPbR;NQ8I<QK3_#SJJ>0>tWO_1F;nM.O@,d/lR:t>LcaY=Zhl<&:W8am.T>>DK$U"DC,T
0%Xs$bOE#6DQqfZD5]AeEi`#YEi_cTE3';q3u5E@0C.'l[u[LWK8la#IF;GXP`(Y3cVM4/LU=
k16EN4$a/V-R`d4<QC_`IlAKsWjW8'9,OdurUOG2ks2am\oOfltfpUBPc-jar@e"&ZeP/mA(
m,5`)VN.B#;gc1)-4"u]A1m.r:$HGErahi;hTq??pO\%&mbG7/6b%*NJ99dD&!&R6j;cee"dh
bW8c`nCJpX<l<Dp^%q:Nq]A?:KOU@DjBXip")j<D7(mqD3^$=DmcX*:ET8*L)SU>WqTAr]At-6
l;;n0&m:1q!e<cU@X[1+"#e-iE6gg&kdqh:cq-hj*a3D3dL0tM\>Yio(\UqWOR(`4MZpo9J[
#YMGK>j.I8dn^YC'6F>d+iZLB6uD`*+u,7X'PVHAnCR+>=\U&#nuB1$"ndoK_9((5>#^nfM@
XbBb,@u4-8]Ain)7AHmL<.Zi;r.iEqs/"Sj1-`PWQanPmLKidnkD^r7%qn.@Wia?`e8M!nR/q
K_+fE_K48NP8BO^m,g$)Gu'#1qTr_Lo19b5b%!IfLWFTTGquFrBRVE#"k)\<;6ttG*&0h2CH
,sA^e5Vdal/cMp&tHc8i6g]AW`97h30a`78jil<92l,8]ACAiK9J3\c9FeGN9b)PAH`FtTmb%'
@7-D+AU$n329@4aJ%/WNocqu;1B*:fb8QIN4>CB*%rMX+ajZuq"UCCIRrM)m[Fd*;(:G0Qb!
h]A1K0D^isb"6oAr__$\]Ala,+5/,t3a>3F=^5u`5Ka2jO$c^=qO8NX:jZB@<WD>4>jTapmTT>
SXn"9+)1`=t:=qU0[ak:+YXH<6^^^\#%ii7.2h_Ra#[-J744$jJ'eL-e*APG$E9H(,0PSO!u
H^2b[_#@<sn6ujq2ViG\]A^Ghn4*DtYhK8Ld_B]AVX_4eQT_E(@MnfbO@`iX6'NN^H7p\RQg`L
nd_L6KA:WR]Ak!^+uqB(&p"<#E,AjbC9$n?CN0'&tpZZ?5]A?WFFu*EjiT5m2LBj?]AHn=b,fV'
f@A5!,@A7f#Y^JOLaqD>"?p<=jG7IWUT935,;Abo?q8qN*\e?@P>Nk6&Gj-p=@SmE:PFY.Jh
49TZBYt^'0>od1n7sH2P25.']AXEa4\%*LEU\9%2^'Lj^@))PXpA6?^7>$cP6EB<4qX.sf'..
a"D,4F(2b;rr7-DV+hd?XWdiuuX+pG*RX79o'9)mQg@'lBa5$m-HNnsYl)ZNlWZJf4+>gHZ7
7ndjOpSSWP2d+G[LAi7Y#Fh#c&%Mi;jTN;N$JIk'D;=l_a8l.gZYt$iVpfV!T#nt#]A]AChsE@
)7bZu+JhQ<l)0%*cdSgbd5tFm'NdS.c_MN`0>]AjK*HTs4/*uijisJ)'_`S)(d4AkfkJ<kUe/
j6Dkq1V`^u<-f&MgF[3et7lF0ih-jNSfWf7M,3`"2^@bC0Yep1uh3ItYQs`!`*ah0M\KT1R;
^BAe&eZ]A+oG:mcK56S3>pM?fM'9:MO=LlJB=k\bpIj$b5(@fOc3t8rcdj$T>-WciVBM#c8uC
kKH?XbjVO#EO-n>W3HZVAuX$5?em>Dr*2$cu!f6fu,KF"PuFsYI`e2+tZ(>rZ?$eOF6o[M@O
I0U(J:BG<*-Q?G&"B'l!7%`Ig,M>5Zc$D_J@BYVDB<[G9bE)B*\B]A^0.ZFlb!NA<!+Z2rl>V
u(V\J8@eB\l>.,,V:!]ATHQ(Q\RQnVjd="CR.07IhLfFo\h#ba=XKuC1Pg;CYiZ?7iE%'C!9q
Mr9Tofir31rrT<DL@hfE_+%5p#hs&?3S`sMd;aZ/Wqc2&_N$+DRY`PGDr_\?aB*pTndFd:lQ
,!Li8I>rkJGOX<(l\YbYh]A!^4FRO*WYeEDk9`!:2K9XVoEa;Y_@'UJ.!Qh-5afau3O'U%D:*
:^W$FDim^]A7;ilp<bk?Q>A>NBU=2tq=.)gWB-5GKioH"j>tjV2]A\?WVM-#DOmgp-Oik?faUp
jjuF^_';LF@:V(*fef^[q"ep8Pd0,^l8+NtYBio"*$I?H/J[!?/JX^ibnZ[MXVBJlTh"<=:*
'(Nf*3]A"S2M9'",#VJ_0j%[K;ra1-?YW[o,'>@l:A`BA<h\1\K7*?gb)2Baf/7)TI6a1&.l;
5;GrM-B@D7uf_t62r;2m!^/89$Fa8s0>tK`-cg,DDd=QU7%)'$hJT<99M*`H#R6kDS\O('`%
&AuANc,_u=r3-"Ddj)JW1(%uC(&B@%$+dk`$G?+<VW1Id3H-LWWXGi6+rtDUDili[(3N"/^?
H0"uF<B3BlD;?#%XlB\f\?G?Y.HZr#=6WaHhkUuA!ROhS\U<>PWer$4OH!lm(!MR0[Z1R73N
F_^-#\u1`%FbdiA:kt5,j&`I#("9St9!I?i(O5fY2%eiB\f*C@A3XN\r\BTl&A6aF7ddD-Y:
[]AQ?hl06=f1IoRAPeY=m>uo'E*P\dXY(!\gdlfc>:R'E$VZ*T+t^DoD7"EdHL8UD-=JpkJg&
IVac^<YB$DQI4F!4E=lr8=ko\>/aoN`>Kb:riCZ:pM:THj70:HBqimPU'#4)nnrRf0[^P=1g
)ER3ZrN79k\?jl\KF=beMdUeq2EsUK>q\)23!qU)7$^qBQcRD!+U5,`4H$-S`9[=5>:L]A4^M
=o(`EjU&D4kXYr_7JG7ioQm*#Pj;AE>u2HOScoh(r:M]AnrB[?Yhj[!C3G4ae`idTs7EO\(Tg
g?dX#eEqm+pl#[.i-nc1Nru<L"SX@f/\Z.2Fg?Xm7+%/):k4RLa0`fIO%)c8N3*tAmo4'1$I
K_NWqE4r^Q65LP.UA.2'At$\O,b?Y*,Cgj<5U`n6Hj_LbCSmFF,ot`jB6;dW@[>@4s3fn[3P
h7;Zl2S!7J+RqKWm6m(4ZYd%Kb>l'4.Hm`jODl;1EVQSBLs7,\YF!T+6MUI#0o4m72pU4,Xo
*N\N-TA0;/Mp%7CHSk%4>o%)keshjqP#`CMP<_e14Iu;%eT/$$EB`UQdM:Z#iY.(QP8n8MIS
Zt.t@&aR[":1N(BA6MaPL)c%+-%62=,I2?]A%Qg3c1LP)A6^->&iSK=*j!e3Yg]AE=u9>kWr9H
=n6A$[1TCR]ATkK5P@^\fTB#VMO;EM.^L11O*6^E=L<kB#!Q9/kc.ZDE"VMV?>Pu+9\[R%X/3
oh)rC?012N*YSoQ$]AWg.Vc&gIuZ<gU,Kl$Jj7N:Z1#W(V2i*\]A^pn5im\ZdM%tsM&o[lNl*[
ejn,h%RXhtI)a+%la'Pg)@$S:ePk3]AW`5;&Ffh@]AJ]AdN<5_MXg2=1f+rll&-,gVMl"5C>WHp
3?:kK[NO%n(c]AQ@&qpn?^1?tGgo(43)btQFQsR2q%st0QW>T'[spij/oXZkO5M0o9$u%5bMU
XdPP``*7`3#T*4g<U2=g?TP',YS?=ph<9nb&mKG'V#<jh!5lP"Q60mQ\OmJ'NXJcDYWQ=09K
1ka?bgJA7s\eJU_L\HT!E\LdU`QIsr5afkhm6q'3/AdA$*YI`b8FW#&eHF9F]AP)MrKPc<(-U
JhDPVOPK*bcmcLOFcg>Ma/k`KG_"fa\^HZW%5<#^L8kpm/2`;m7JV"o=bppVpK-lm-Bgq%V+
KnuN&84fW#lllNjaCk94BF]AQR,']AoXLI%3'&_]AQftDcP@Z;SJJMl.NfkoJ;@#VU*Rfph#!sJ
E`R@<%[O3rEC\L;uMbl+#*4#%aV>_Mip$DnApj^P1se8Idr5IATX:-0uVFlO`@AM9[()W,uQ
YO:eWJ'[;.qRj.cu*BRDM.I'WM/;DN("eboK,+(MH)j0-n1O%?NtgsL%75-r_tXAnhS%8K_G
>VZYJ$LP(Z%DE8;;jT_'\CO.gr9;im+2R?jnG\s4<ph>T1`9-ET+G.K#UT3;i#ruSl&eF1$f
dAdm3Nsj!P!ruK']A0DfjZB/,(UDIcqV)#"<qk!c!0eI)?5AK_`&DF8FXQD<QoGQ?f5`)IEpi
.Frp81Y049e]A8<%C\;?cm\;,2\Pe"^&kG!(Z8l>&d<g`R0W?*A<&-al8d^1tF^g-B2=LXY-q
PSgs@'k4%BISF:$b"E;fk?jJ.rN-e)M*7.K'eN&.pDB4#s:nt#&(I#O\"@Cf-k9DmS%Aj7LL
ojhq"R[HP',b":u?1W@)\L3`$.Y9p.YODo*QS.(Y/Wr5?riV8/G.f?g@dPID4X`uSq&NZ$I@
*s=3>M'FWjKHfWukF\DM$E55d_>]A(CKmi5?CIgh=)(Fb+)r*Jj"*AfUD(sM"YY^1U*r%E&A8
73!s2nhr"6sk&7-'.&MY)@i0Ig1,is`oQ<K$h]A:2kTqde5j=)63ff"^fcOlfDu3FUebG@V7s
<(2oE]A]A<6HgNP+lYD0pQ[[m$/MVM:".'G]AD&,n\u@ap%-1qeQB*1@YP51A-?)#AU$qMECeYA
<L/P>E,V#n+\ErjKA$"`1"D9>X+LUg&F$gZ;1bR.5'%hkrE)L7Bf?Se=25PF9n-Ta7.eScrU
8)s%qGS?AGrL-NQnAg3H,"I-C#!</U/8""aBc_;_:._6,l8EL<tj=-6>\SqhZ',KPI:n95I0
%$f+`m;/^e#3'iTPit\[n&TpcDK5JGV(LLpJ<Hh-e`u9\'WVj\gXhO5AJU.Ye^$+hj@iK_R)
V`SKiT&3eIC0(If"-_5PB+EL_25_&4%oYrM+5d?u0,m(hA;o$I-pu%KDHF68i?lM11tj,p'"
Yee9fcF^ZPE++I/fm7!32qa1n4q]APmrGd0ThmoG,Dh]AlM+no3adJ%?Lk07Wc+5d*c3rnIn;h
9PU1K%GFs)!B&(YMupmYF5[p)KU7mZ%S63XnIK5C=%H3lPn,9fQBbaS,Ni7L_di96:DuMD_:
huRDhqBK.3$R$'1_/F.L8o\h1$VZ%^^'l#OC8!Bs0<Cal:J>nN586cp88VCSN#N@V(X+sZuS
PKE*RjbQmDkZ$JEbf+/0oPL0sbpgC+BT!+oSH$oJ`2VMf2iVk6!pqO/s1^;4Dr*_G4I8$Wl7
>;%JSQ1%,-[d!NORlS)=qh_.[&GrK):fl9[WbH&Q^B=7@c?^l1YU-HY//YZlP*9Na%[f$#)A
PHn8VTD*c_drZ:i:\*XKe#;E/A1\38<Xm1#rb[+r=nB_iF9bKUG#3)a@/W^3/T4#4QTD]A+#!
\(E:5is2rr36!DGtK]A>Z3AqG?d$4[.c!G(L?8L)d632ZUGI1Vb%_7P/e9Q`Xd[\-9JOE5#1r
$j-+;$OlI9]AsSK>-=Q8!^i1[YE&)PPuZs.h)?ru.G\@[&quJ-u;9G'nB/Z2tn:KnX*kW9*eO
4/,SXWtJ5-M@'VVrM4cJ4)?bK:g_`PBGPTm:r*%8G=,!?DpoI&=_[lb-&!VmaE)1KRp'jYq4
2U4qMqMV_+(3/f:@`VN5gR+2bnm6R5^7B)CdUYWIeTB1?KI*[%_q9M&Z]AHJ5[:;P(KjU[7*r
C*B//lLLnLmK\B8XY5Wi'H?^O.G]AU'3)p8+gah=\;k482k7G]AVVFa"38WX$M"R*R%B^Qn(K2
BhZbD^lRVX-@(glZ(:AW:@'Pfk$-nFJ`&X3q*nlbXP^X[oAqKFFMEg,%%`(QQOP4hnj#XS^D
,_H?W#/R6W1n+,ic8*#H=^&C:*-85/TM4sk<J.Zb1/P=Vu#;\\r%mGC>E,)H0Job-LUWO.K`
@>nqpam420Y]AOWQ+#<PIJW'PQD58rr$qDD0A(7#X:)lRJf,/CNl5K2OjXaZ09#G#iY+0B3"\
2D=aP1K,Qs-g%2Uo:0^S.dEeH&/Nhk>@QV:Pc+*;&:h!t/:Ik+<Nr!X%Tk;E7<cUt(*qHpC`
R%[HR=9[QM.V$P5&)Je1N)WJ<1S"ZDPPSc.0>dlUQo9f!.E@<?Rfi4MsjHnY$P5P)m<BL`)C
(7.">J(!oCS8oK]Annu=iqR>q`UcY`Vs&_m0SGiX-cBG2(_+!SWn1(;Hh'+jaRUm1i%[0'qGA
oN%LZ(!id`;`[dd!80%Hd@XcG<)ci.(>@-B!ZVSE]A*GNk_pN[s2*NhNm#,0h0;W5TNVR,X&T
&nUBOr^%6mFYF:WTuA@#BZZjt28=CMTpBg=%%%1:aD3d!f8'?r7N`$Ar:/u5AU8u4"=VAFee
j2r&.*M3(jqjW)YS5Inm'%E424C1I.%_YRj<#DW)d<tJAK,t;Bg5S+CKt;VesDnZpFmO#?.k
I'`"`O7FMm\[&n0%qN\i4_"60/=M]A.e[?f?r=R#8l[X2i2:\Xc2*5!Q4c"([+YQ,$O2N3?ck
_,%Q`$(X@I(]Af20&9^E`M'hqc\Jr4ZAo*OUm/2DpSuVciXnr2b57gh[?:=81g)IUn"<F&KO9
AAdUnk$KpOZGUaM`kB;=DO'E/ms/cU/\c%cr,.i#/@d0d/e4=RArP\*Kk2F6A:"KTr.rD1uh
$,.ueSc2E!Q1XOco+W[<=(p]Af&1+OcGa#0VFrId!,s#n0G71reJn4=EW_Zb!A_OI6m+jW63G
0o5=5TTjp/!GU2ERqd1%N,V'V'E(9`G`#-beSj-XpLf_TrQ:IJWB%Ptau2bEOeY(S_Y>nD%h
bX:GO)#tY@s.7%9N8mo*#Y9>kn[##G31XH$,en\^/TJLbV^>_9$I%WrmFjAE5C0r)nm=1H6!
bqoM(WEUVk<a.';_KV0AQUHW*P0g`(:`)pTo>`]Aa;Rr9U[7i6(DJnnn$5B%C5>1s&q%J+&+J
:U?[b/r:TW",fpnnVaSi-!p6PEX0<0o!YZ\n_K@R>4\L<_0E^LI1!&<GqnoD3lfcbjib+?3(
-Hm^Q&D,iPXXMX&`&*>]AYk\5aIVXpfG;D6$6M138dV2*>L6fuULLP$#_[L$NOmg%2cC>Vt[u
/4scYH?d[Lj]A'Eg4c=]A"))$Q-GE93YrXk=S!7PFpR1AdjplUoro3MTjGWWLuFKE;s/^;(]AWS
<gC9B[s0I"Tj-IgaO+JL]AJF\n/d$#G*>:qL:&hNOm?`Y\g!T@UW>7bXhL7]AA9\d(j1`ut&nY
@i2?@uNU!1^"hDTrA,,='TTX-9\+Bd"b5;G+:\3:e?!L8j9FrN&L+>[1>atYO99ULT7383Eq
P*E[E:acZJEgZp+1!>aDi1b`iiVeq!$0eH&0mktB+aiGIl"WLiOlpV2-^BtMeLfa<=^Zo58d
K9c%ukC&2Wf!3X1Yi=+n!s+3O!`:mXI=X%XVfsMfNiL9rO!I?URpUdEZh.jZ50?f6!sP#G*C
AIJ$&`P2/Zf1[aOepbkcE$4\CZNV&r;KR=Ck1l[rgU"N[<XL.9T:pm;;rt7g4AUHXT5qepRs
7oO"+;Ft;MrQodRPo[,k)CN<W3AGNZT)U35SA!"$a*)2U<<DM@qDaP*,O'f)gH"j0h:RWFDN
YRa!ms2$Q%X$Go/+eVjDc:K*6QsPR$b>*L$UQ$1>jhbOL]AT7YX2BTRF.sF1k5nQbcHiaqhXa
h/5Kf>UZ`'kfZO;G%fo0Q;(?'U!UBgs?Q0Y`Zr7H2&/d_%N>+mVI\!EP=7X?-Z\-lX8(ET/.
H-N.;e9+;mdL"CXe4CX3Gsp6lj(>^#3NLXQs"SuW)68I<jZdI;YV[&("K3\aVt]ABB3U?\d5=
f*Q^cg^5m:A$VGa4G),cZn\n)OB/c?<3;+l]A4-/kYAs!(:5MF61gSZPT[e9I5npLF`#2!:4]A
Ph7.kH1oB9@[4:InodU(L05J;*7->8=R4eX$i=uWbAU]Ar0Ip3`S'A[1VY?L4c6`cPh%#(R3@
9D=,Td8Q;.qq>!$8rPpk.Zk7&Xn*idh3P:]AAfTn9-6c756@-B(]A<93\c(oRqr[Mg_'h-_W&P
VWk>:q\4,#D9)72F]A[.<9-:Y(X-S/'QR0\onN0Hd5oX9_OWYX[PIG:DH<!!ECTQ&M*M.D@f"
iRW/eg)^5?c:/?sZL'c8#-EH\TWhZU8+Md14/fe#Y?M"a]AfJCU1n$-gl,l!D-Y+#q$p=6WLW
q`aL$cWqMIpF&Z0GUE-Km&MH5B6ekHKBT2Q^E[Ue11@?W3O:l3i@fir_A!NtdM]AD'rKh1/ot
+[`L*4$WWu7@n+Eh!;!/**1oW1es!ld-O!JBT\bl4K8=pS@J0G%pu^GSo796_"WrdJ(*#(QC
L1&X+oLZsVW+5a5'<@@d[QWj-`O<P=*[Ci3>\$J[Iq=Md>TOM(H%ZJ?;.P5C@6'UHliD,,33
ieC\SZp:^)Ha>Z?lU?;t#uK96&9phs%l,Cq%Z97BIE3r:VZWp[J_L+7g#rWKh1"A9o!I>U:*
=Z64a%&`p"<5HR@3>u@%PWL9-DKG?.le8fAgX,.^H27-^*l`Eona-2KiGFiklglsjon!Q\ON
&nh,^*4t_^B+YqP"pSq<H;_\^ESV!;K`U0"urS1+,!G$VpmSRS5"Ke0o\9W[R*,G1P<H^\`h
[/+sZd7M@S5+#L+Zq4E&PeG8GVi6LiTel9P_e(TYr^D.FTcSEXP3lJL!UQFF]A@ZJGG$3UVMh
]A.#ans<^OgXU09"9TuoEW7>A!0VFiqA#,CI]A5q=$K?u5;1oY7p-g3S(B1Rk!iVTn_RPX1hg-
;gGUJ(5EC0WkE'2+h5AG3rrAtDTOD*]AmkN/2XOHVs&S$,lJE.5Wq(#_5=/jF?VVee\MP+B]AV
g'9OpX/WdLLMLi)g_T,UH[c>Ueq45@q1`I69^eaX6#utIN$ba[f32V>U/">dkro/C>u(L%KU
?UY\]AcXq?[T0cAXu012h#);WbYFRG1bNO"gCGt#gsMd,3.dZpq,2lfTTV0aka!?,j<X)8lWM
b8fb%Z2ZZVu?IoHO$1FBd.#id-bhKbiRPo>2#n,Hs)&9Z)Uok)s"5i&WHIfm,OcG"!=_4EF$
B83X'*k[6pLGk7Rd:'3$%OG5Z%H]AkN`K(u)\mqSmqJtBUo4_G\23`2GareTX)#QLG&:#;C[]A
3o8e1nTZ&9I?0a9hcH2`rd.'p(&EZEc-&I!VZhgtqXhFmbYa8PP-L'*AIg*h!?KcbB`EV^(,
V[2]A`Wl8jCWo&m$mVB2!&D$Ca3eIu6iV026bM^Y#!ab<%G80YSF2%R$f%L`7Vq*gP![@80pg
?&!;(-DJQ0(#G7usZH$9E`*YbTWChQShgcWF_#iV;uMB2?$F(tA7GS='C)hY,[:$8TSK!<%@
3mS)/T^^&Ya?N6XVB)VIcHcK+%"b(*53O@6n=eE^?WV`M"G-4i<MB86UN-N%=)@&4]AikM;Kc
!&Oq@?mFiS1cI^W3U[nc2e$*85VGgCkj9dh/DfV!^g>k$dbeJm\0QV$mobmWCm3oTsM*ERFV
4Rgp+DrS%f/=m*7`4n#'Hu:CJ'fc$dM*)E-G>''2XJU\4K9p]A!MhMBn?mTqHheE8,SRAM*,1
$]ADS`(UX`k^UZ@5nY<t;NR``q[V=)^S2ASZdFT6)GaKA![SkJim2C%GRMsNC5_2Y6?paenMk
d_-GHWf05,1:3Y6I!NYtYgK5Fck&WNc**e/C"4Oa@Oig/>(+q5*H1fCMW15*sULd.@BbGL*1
7+aF+o/`%h8jGKF:)r@tGf:s=A)d`/=g5+R;3nX.P"(\\!%HAo:'oQ+uF"n@]AA]A1e%agma:*
@ErmPS6DR^HuauD03fVK\h2/$1L0;X9;#n!]ADK><#,N\l\Yk'cBZ&<LeO815\u-(_QItK?Z+
\f_TSdiVK@!;jZ+e1kc/m6:FKc%a!nAXo>&;C5dXg+M)5O_a\M@oifOhY/rG#"08X[Ig?u,4
WL]AW1qrHkOW/jH:s5qmd43a[LF)9m(Z`>5Y6rK"jl.PAD0'KkLS=Er>VG(o[Gg0kpl7PH.ot
tq474N2,)BB/,NqW)t&GO[G^QGVrm9;t:lMo[P6J,DP@VO_&nN``A7"+54B$^ds+#7HG,(DM
gA2(^N_TGBpXo7b21q=ae4KciKA17f^!Q<X,q9?W@n/JT!!^m,Zj[qLAgqPW51B;D[0gnnjL
gmcPnB#@6JOJbJaMQD\3Y9Ra2l:%nVMIAqRbciub9-9-[:dudL^=0U-uI4)^iV*e6D#8(]Ar@
rqS$cRNK3J<(8"S(MlqX?L%B1!b_:lDD;n*q&ABT\Kf;O;0DA'-P,T;>CB8ZbP_P&^>bE$o)
+W/7\oP30Qh"<nLE>*Tdh:L9FH$q28T07*;B#K[O5)AI_S%U,.V^?^!MCUg_HR#k.,$Ws1B4
\\M.LG53Go9haOrZRZ!Ik-AN4?ot9Rp=(I)9@Z:.I2b4<T#=/=q6WDArF%0m$B8T*gA\OIML
M!%oQ6!b1i!PUP9JJ(*8\p"*TX0U!p0%Us?n)9Kq]A!B$jI:!hL[a\iUlgeer\,.$mlfqVrI)
KPe`WdL`9b(W!:ndYo/dpF&8@*`l*gK!-u4QH:U(IW=K?E5;+J3J/U:XsT[]AX4m4EcT8H]A8u
4Y_k#pW_.MLJ"i!h.Fsi:9BFB.TcLta1YMo\W$/<4$]ACeC_FR$1)^pF3DYSHn,b_0,BZ>\9/
.enu4)O,>gCFGORcXP^#Gl6WY&P@bQfnHiuWb;6B@o@>sRQ?ei-Ai9D;XM$So=oT,,TIc.lC
2EM\&/.e#)TKb:I5#9!L^C@1kfSji2B(oNE1cjqX,>6#3OcH$k9!SfE=>/n+qG<b3DEhcmIT
5Sk:>\R5:--D4O1[m4,mj9ck<-BsKG["ggp3CnQbtK1SDkQGo0>ju2Dn0pO0-F=mE!l%7r'P
5&,(2A0@@>&gKJr:F6?VW18lfB_sX8NL^G&5=2OTD*lqC&Q)7UHplhdoL&e0'LY@!B@K/[7e
;M1pVoSZYTFVk-Crc%MGd!!$S:&r8PN!"I:e@FN.*EA:mdc5jA9\^<r9q<Z!dWGT[F(iE9R_
@`jIr#s[FtCQIh40gr,CYrqs!kj=WgrTPkEVI_taT!pZFVP1]Au1#<_!06GN3HFZtSTf`B(Ic
\'F*ni,'JCI>BU8e`t7,FMK2Ti^/oNQ"$bS_Gj@m_H365tBGC!'hU%>YPIXAsshp5AkO<<>e
qp]A\T<m^>&TB^@0.,Yap$5TWpF^$e35nO%MT1[S[Xg^L#]AKZ*8&687Cr[!IS]AI3nN1ia-WV1
&C`!>-l`t6C_6fX3iVf]A?jF$GOdGI(O?u23"Ish]A^_7[]A]AUA79(_nohV:Y+(J!b;hDCCQ\D`
E-]AqNc#1HC_uc<>[gj*,e%-u7r:+agS8EL+JQ!>7G\n+K`l;"!IoOQ4@jIXB'FM!XNdrqjGI
%K4nN3sEln?-5tb_n7YIo!79UB<!uR^jW9%)_qOg`']AWed)4Drf@[K1<p+3OQ"%+J+8u1'`<
?.[QB9#4ZTumc4$lIc<BF8+6i@fL\noc),6C1Xe<ut\<@!:#J'\JI@EX^lhb#8@lg@a#1Vq@
9gHOb\X=+C!Y$?iZE5*L/fnD0DQ!gLl(Nk$`"fBd=,/8tS9S6;?CBHY:A*)RTY]AF%%3dcoB;
I6LF$kFLeM#d95!bU#$c`r#ZU+_?J2#1^]A0+ZR9cb=&a<D7+ccir,dUa?^%NdY?<iVbn-9+P
TuG+-tARGp61,NAa0b+jLcrtRg,kt4r(5'\nZ)\b[hoR.cgf,r<,cXs_H_tF8nZS"8^U,.a'
A5]A\T>0&`cP9,OD.^$6Dd-TKeDQ>9YHgNJC2Q'EeW<R)Or]A*';#OO$(qd1Eh:4#b+B6YND@K
p1[]A4h2(MFFH7&**S6D52I/-DRueI:I_D,-6!RjS\!#qc*Qn"iOFq-CGT>AEbo(PGb^L9(ZW
l^#)67#k(<in?;F(k8!q'_^XOd36hX`D0$N-kMLeHGa,ums/4ZR+p0%ha*9l=-C'O)mPB\H:
lLk0Er`PcB8NGM4NBm]A8,JufNacoXPGgq9;tXR"kV!2uC+b?aVgs!^-@f/IEQJ3EcIWHa\&k
!`V"jh`+8XdP<Y''2YBkc?G1RN_rlpO*PlggpZEiLPA?5VGG;'lpjO"]AMkNk``q'ZL165t_I
OhqOrJH@pbiF@u>qWE?/ULOd).?(C!OVGDpZm-j;IoJMFLNX^:K^#doceZYb')`dLAQD[$-@
ejucaH9ss#YZDFWV"d+"np(:&b1XG-o!EoDl:?/Ii=&A1p$V+Vde`/:_TJRi(G-g`o*M)IEK
:#qJB/l9fU;mUT8NZ+Qcl*jb6qShf?^(3B.Z56LbE%?;j^NB>@.4QK&oeF6?f.b0B5TC\[17
?Wb)i$f2h3-C"Mk>i$JMkXUW<7"6r-+"6Gk1phW[EO"C.U]A02S]AOMJG2%LU%h3n@_[s7$_^L
@&BL]A&1<U4RJ:Aa"UMb)X<9n[`3K>KP3NO'+a/"W,Z(V48H;N6YmJ#;>-B'XZ22/Ou!:FG:V
aS5^s+GD3@522=@4r9:l&?gS+h5^cF^o6-S5^prC]AT.8%dD^_U.]Aoo.hg+uJdN,[]AT&)RSS$
(@5K"V%;_&]A!7Hob5j2(#rP54:@lnF9,h2cfSF[stsVY?3Jc0\]ANlg<0bdIBp)a1lP5o&.rq
"r0:*pc-\7!4u&<REnR_V_>''sY&j2=gh4;G*>t`+s/.GmMQcC&RY<i3Xc?Fu46\"2XKZ3h[
VacBd]AmXNl.EH3FE6s0q`F\'J*5SXB$H6V0qM6"WbOXp<;.abX`p@nlFX[3*`FNTo.o@h$[0
>^;&lB8e8m;n[@I[*#[@Lr#@=sMQ3k/&-/4p0ATpnaVn?kZrn:e4^9Trm;67foi'*!Gr%>PI
^V^fOLgKrQLtOse88dbU%O7K>?lIqbcb<+LI)5*hJNP_>K49Pq[O]A\mCOEC+=P\E!&"bPSGm
nNg,U<gEqHEX*lr(/o/N0:a<<_H_ZM0uHM3(`f]Ad;]At9Z*]Aqf^qsaKaU#TcpFb4PV<gKU*9l
@gOSg@L[8U)%l<Dpk$-GA_[$F<[MXJ&_;FY*W8kct:.3oY1L#Xer%R<r6_m1Ys';t?cZuR21
E=0Kg]Ag,5F`rR:A05gIYKj]A+AI@95+kT;65c:pdInkgR)MTnC7:Hn]ADYp@9rZ;urVHcU)B!8
t3qKUG2#pfb(mnMY6CRcJ[i\Mc$<2Y$Ki^-&W4me4#XPM2'&7f4G<]A.F]Af%:f^0L0:q^c/s_
^_&J[?M>!T:bgiR9q@UU'q[aQ5D->44e"nZp`.Q@DM7!ZZ\9N2:RXB)F'omU@c-0]AoV6d,>a
G%CNTPGR1jEBLW58Zi4g^X+ep?o44I7R6nJ!u"3]AldB8I[rGS/nju0TT>k0(&1?"d2>[1NBj
kg&WAjqB4H?p1E@sX0iVjpHuu2IP5(1_aj^8$2g!UpW;h&NGIFn'+/MIgt[_95,UOEf2`qG3
)'NB0-6DY3uF8r-.mLcSW9br"pH.-ik$ER[B9:[_^5>801;r=S\]AZJ!NO80c)Z-LN=,0YPgA
r3c[CY%3[\3h`J5I[cO^Mb6U52'3;acTG.\tDP?T'6T&.AZAs`8A*&1u><8;9TZl%NAUsJ74
c1=ACg;-BN?Gb4gD78V#[U'7lH#a<"\&rQ_;\bVpl"2A&SD2A0T0.u6q:AXO;$VG10?tc]AoE
NfTI&5=85`u5J=>HHkT0;JN<8mR8:dhi2_/CX))C,9/%>r=GOo&4!L+Cr=rUUaMiGOeP\a@"
^M*$LrLS*LK^ogs+^6]A76Hi;`oRF%$K\O;?dG\ESXL#t#$,j:=8[FL1_bZAAsHD[0!B_(4eh
s[Q+GPn\g_`AodIh,A:*HFH;l[Y/>]AS@-C$gGc@LY%"[Y`6c(_pi&:a[3IK7d=G9Nr%gR]ASh
#X$maE9FJjHBBFe'1XOhE"[0R:^NDUrc)c?jpi=pd:fq;2@Gc4C&XSk'#p_K)GW#^CXdG-gQ
.c<Q]A]A;d^$E'FOheVQb_-'\DWE1$a>cosjIr;7PAHie8is/JsYo35o.6+XBeN-j#Z$u#tbng
L"WXZ-,=QIk#!A5k.VIZ1;VpOipO-S0qQ58WRt&I"1?.]Am?KX6bJI7nCMF86O.RSDlPB.1;*
2I;GO(LdI<rKhJCo!VeH9T?mTPjCAKqo[QbD"Gc=Kp'Hf'i>jfoXF!E44fNVZ--O?)`0WoX=
k*$RnOED9*jdNXQdGX5`rra7Z`)U%Xio>VXA4cuLW?FSlR,Hmj.jmn;q4+6GipA+M_Mk9c`J
s5^_Hu&X4RZp&4,EZi+m[]A^At!Xg$.,WJ!oP&6Kip@(:u_YCNS_'+.Zbc0nCZ/f7%D);cn]AB
]A^t;Sfa\<=g3;D3f/bc5/;Cr,CIS9oc#ePjW(27/X5<qGpWVN+QmZ-CQ=<)@6pV-.H8cSCl^
>FCEU6tH0!g-7S(JEs*+<lFdD%o9e"!L#q\6JZBofHiGg__7SZ"IV7QL\*4=KKeFP1!P#4=&
H@hX#m_E]Ans4,nl!\\`b!7ra'pBh'q==JZgI4HG2b=u_'8:1G<)fjaH[d9R-/$'^&Rg6-FD&
WM0L>5S>hBnPokFgsg<[13A.e8apjq,;!S/edjjH;Z>gId:It'arHDYPf\j864Us9F5indH2
9Yc,r&p`g7P##T,hW[OB:D(r/h]AXLT)/7^@)79[5>t&Qe(3HJ(bUS.9_+(65uVBupPSKA<rD
#KB?]A;(pY;0qs-\`H%2)?+DT9jl.BuO]ACJi#F%eD9=PLPbK3?>I/C-\>J+=gOU7n`b()Y]A8]A
2BF[7jg]AS>,RbRq-n=)K#M!b#EWa.8k2V`!"\)7;Hlc@"P`2X'lb?@GA*4@Dt+P/jqcJq!Y'
BJ>hZ2NpD$sDJNd[W&<gYgmNZVk*&1pU(H!L=.Ygkol`?5f/AcKNWs9K5,hJ$Q.)6m]A1)LTM
?!\sQYkLL>Q"G/":A5!X<m%%b`^YFRuBU`mKk=r`IV`WmZF-4AO\g&VmNG_I@C4*or*32nY#
,W?SW+D?VAtKi^7JsbM9#>k,[7J58s'<r^%Y@7(lZE;:gFiD$M)KXJR3#qq]A(:=H#-^@A9N$
rQ;JSkhE#1)5S!TH.$k)K!jFi0:AC$)b&*a`8Md-Ddj"I8q2Gbj1M8kZlrMJQ*Ci'nAsMM((
kJc!!N=/(5tm'Ol!"Ca5@l&SSc+a\d2>rQh_acmCJckft:grH4qGJnn_B.F\J=*C]A'dWaA[\
3cH!Qrgog8"a>$8]A3kMp0]AW]AYDg,9Yl.T*bn9)/I#KD*dQ=?Lj6[_K4W(&,K@+VGMuTK!/QI
/jLs=gU?f>"2BdkV@.aeN;":geWNN8(NgJW+!V!V'YL4ZjbYZ,JR_S>fk%!^VgY;(6/dra4"
7t#e[lWp&\1l6M6<4kq-R6`F>$Qrn0sBi"PCi^?V8]AluL*>2ckhlG:c'T8V?^hl1Zm?9RYr$
O*MX(T2]ALd*.BD]AMf\Z#Pa9pSpa8\-"KGdiT1#PFF.IXCV:k:,SSmRebl@'SH%M$5Sr)#^/'
)G0.))Yf.#@6LS(Ti/;]A*)\P?W3#7r_#Sa;k2;:mY*81PpAaXJeZXcf0;HiIXZlf$h5:#.g_
S.a<@qVFBNsnF=n)r)j5jbQ8en+<POse+gql.#lGhgk!$uCq@9]AT"FlBam"NH-HqGYdGe1nb
-&7+'_\X32Vra<Cn)Is7OuaAAc+#eps\i1SZ2MbUL%K>W$Mr;UPckU/^ccg-Kp&@BQpNK1dg
lGL6$'WVTD'7fm*HYe8E<YV6^\qV.5nf)8G7$Mefo-O[]A-aqQoMHNoXZ%ZEON'Il[/Z(]A/'5
RHF93O9OZ'03K0[9U??SE^r[)l`BEbKRDpT<GQ,J*6g7:B%d+9/=b71c8caY%6q`5]Ab%O':-
>*u]A[)JV>;Uh7#KOGqKo(Zk[-:<86YC:GUa$dU[QL$B38P7qTA^ag"G^[G_DYIPRqJR>j88H
F3%.</`[ncDWP-qK+P.q;+:1>GUA_+(oXFG>ibf]AA]A*.*l3L,BcD>A%i=Z:Kbe)006R?<'r4
s*-jA#IeQi5lXjIOeR,p?@p!QkhQ:cY)^?YjkSE(nD2DgKL'9@DZnL*bq^?kH$5]A5fm!q!g[
?XfY7sWiaA0Wju*Z5H8E,fB:$7J<=69N]A!fF"oQoIYA?60an6BSBR^7[NaV1/,du"(]AI5%gO
6uAQff\^Mof`iHS>_9gUOLB2l3l=I(KArKSou'Y<=3dNp?TI=ld)P=r<gSmI$jZ:+dt`!VBt
o'L\.X^sl+tk!"%bTb\`Ai:B6)K'IYl'eeXkk5ZSjANcVYHF.G:6B:?"AXT69@mr8a<b%d!q
L2\0Tu6t(_\RoLM5a@n`+i89jcZ1#N#)E4hJH#KtsT8Ih%\#L8;ZO.3K.5D9YT-&I^_94A?d
bZJ2fqirT?X1'IGDC5>M@T%,V5H>FeXmjd2JS>B/LLce44Rl28(Qi^]AH.lCCFA4Uo\E]AA8%,
<MV!KBLWdI=]Aj]A-BL3]AQtZVdDNJ\t+N86%_O"\_p>69NschkS!I?dST/=\g')ZNDDV9-Ri[)
(,[``=RrP(e)*GD+OaPU;Fs\NG@ZTK\#EXFqVOY[+LF"P;u8]APF[De_O0l?tGP(2-)I.2?mo
ao&%Q,;UO[>IY8=-<Ll=.CV0(.EQ&=1':8=>fFY1FYaLBj/an`^?T]Ac*'':Tefh.1&YgQDnr
,B2N7[3-o]A[hfjsu2W;`V?5\c7?0T$3`h'L6a3Pr[7MgJTgt3mm=<3`I"c8%rd8h2,k)tW-a
n@L]AXH<S<Dlh]AA"i3e[hq>`YS=PVfE9),g8m?OX,d'8=0t!W5)3'Z+DG^-kFMehJB]AlaMSpk
i_HG+:L*imP>cOWgLD#X..]A9Ze0E''dXr@=)=kaFkAjX?4nZXZd64n3`5?2gk16bdsm9uNaY
"?k+$E]AdfRl<quEF')>Q,O8na4Te2jf;:5`]AKP#@mWI7D75FjWOg`O+mDFFd\b1tkKD3"<9f
4!u<gB&a<l`L2E5BmDr52HSG]A'd`SR4"Fj7d'U@q9D4R2q"?n%&[hDWi0i"1d.okQUc36f?4
"=9E:N14";Kpfp_O*B"dj(W3Zm2LHp'UV?8X\GmU`l#4q)rJSbo+u!nj5<1E35S;CsLY)2Al
,H\o&-A0"5@>gZ76K@XL+E7VC#e;ee825O/j8SjG4Vu>11lX<LB"9&=qTLU48GG/)fIZ+;3G
]AqV1#=^a0BmB".bM01/_661Z2Bb;cJ;+TDUskI0U8b\Du?M"d0'7Cf:Pi>Qc2SFDg]A;kc`!/
OZDAuP\%c$G.qmoCA1qsA-T(G+#&(!2d@DOmY9nD=HC&N^1V[Mai:tDrOq&p.!qNN:0Ga#do
#l9=P=dRkXJY!'Za6nIe:u.[Fm=R^u%bGHgZr4khtK8iAtc24;\4&:T7fMY\_r#7OaXeEQF&
)DG6Q*'Sr0IKjHHs"4[BndAX6<d[cN_V/f0op7[0q%<s=X8KIE?0W6`_jX9YI0nsg]ARNQNpr
2-_pI4u/99mnUSR/sq([ZIVe]A^F.dec/'A5[3+eogSR[9/((K]A%=9E&5ej`LMrPJ&\;b&@c&
u.i)QD_Wagt4*&4M%F7HgH#BfdP8i-8GU02cFcbA4BGAZ.s`0$@abnHECb$1*ZC"i2^fXs:P
^(VPrgE<Mf!@+[d1N8%!.Xr3qV$Whk.n&bA&1+)o7V8n^3m&TLg!)D,DIg-dB-15SDf_+C=+
:6A@dq^'&:&(f8;m.0:(,T_MuSC+@$2I<f;0"DnY8DK*LJ2)=>GY2/@VDF;832N`.1(ieSoQ
IUHSjYLTq0)6tofE4CNm>=;C_3V3f]ALFZc+(.'ar.*N-0'Nfj)'s**KMB'iY1DQa+*^*0u]A[
g-3c'9$u`Q'4[gc;q+tfOe88Wok9Skn`7K#clE#76s,$P>F',?G@:sK8m9cT5jHj&S9]A"6J,
b"fLWc8LRu;0!ME*s!oV&,S%V-BS.k!(DkpH2_dSg-15)s4+N?AhLP=;0CN\8CnGp/GCu>B`
p,r01_dLl4;aftnkAj.<U*S$TW'LA"-KMdW59la!r(UkH'5`dn[QVqX(ks-)f`.u+aU!JYO-
&tBf_s3dpI]ATAooKVkE5jiqZVN/cM7)Fg8fcD:X<:J]AVn=j2cj,Eh?jk\o*TkKf)W8%W+_dB
E(oAbST5/"b,d'tgT/%\l\ufb9Qh*GKDC/$l14+o-!"GWF$dpJh)\>!LF?S`Slk+ehT+$haQ
n,Sc]AOPtM6:EnaR*N@8-0V.RkI-MOCjA7hN!>DigU6P(g]AJ,?TpqCB,kQ2?>@=qR29#qYcBF
nZ.-2u"R#"d,(l23S-q=:-o3,B6L@oJ[Ti'3g:uFdnm_j^+OdrY$_Sf\Y[Mn-<J"rP8B&Up7
TYNOpZ1q$"1u<'Dn$7pd`10p[miK8!-F4>Laau8%n!X7JfM>:HqO:fse$^'IiMOV(fJP(/i%
Vj*E?O=8<.OhP9W-Y1;n&1M106$M5BeJMBXjT4I$Tk0KsLY!rL#kSd3LffQ8"8#Du,uXoRB>
h%C?.9ahg]A'l<dSTrk(/ADJa=1WX<$f#%j1aeBDd`T"-+c]Am8Z'>u0&JEFLI>osdF(&Ya6]AC
u1q3A(deoj+h`bH0``>pA5Z,\[P0Q0"3e*TgCf]Aq,^/CF%[R/:\pL2C)keT?_eIE\K?6@I^b
@'N+`h>H@!==K0hAUK8W39;j.[,^!>c+Q[M".5[k]Af__0&UqGCS0[7;FB3MWYOhT_:Rg25kT
_fpe#XhnI!]AT)C;!QGlLhiKJP=<pm$RgMA56Fc6.$mBWqMaiFC@KOQZ-/jIB\1E1'd@5`Gi1
FJcm7UIig<$bMYWpkq?I]ALMEqEGR+;PeQ+q!qr5?DrtaJLeiB*#k5fj3Z"gsOs.1EV:'ER6f
:6i)(l9UgmZB$M+@b*t1h<%]A/M.5'/*eD!"C4)[<P>rLf/0ii62O>/H)d>p(XJ"Y:er9g7@%
5j>)81n>8JAR;:!\#C1n222&c'\Mc-S<ZS_\e@bMCc6?[g4dT3rH@`@FP&:qQSOQIb!-\<ll
E)mBp%S#^XTm@X`H":115f2<^5!Z!=3eS>Q;aY85&d6>)"K!g73IT8SWRb8gEHm`U3)iRM8(
.k0oLBt.a??X$PUC_(Uc0_ACEI?oBAl?92P=(_k^"_Bg#/33*GEGE:@_'LfNFQ"GBfGL;'HZ
F7AoMI4=jhR)eN&*)P$*-IVU00ClIguj2fc0['[IJ=l2a=r4%2nT_8)VJY;UP@I3U`-:I$!'
Qp2'i-ea2([%i2h3*"Zsj8R^mMaQL3t$=AmpMfkf2Lu\`2\%33%Lo\-=%3nPLQ:,<rHE@s?U
c<^*^>r&6--'80>9$%3`DfW%V7.OIdGN?a%8W2jR3Spqb_dHrh3gI.D*2H%:UZ`mMECf4^Ek
"KZ4)/#9r$uXcM#sWOqGE07i7`s]A,*CjDhbCD4<$#!V._$QQJsA:QCbTIE2@po(dXDhnM,=e
M'L(Y+e!_]A<P]AYsOl61,(h)'n>96J-!qof:"l/9J*72Ba1*WC::L`?JWubT;77u'//6"k3Qf
SX1L9Zo:`3BKkZ3s;MW[JFEXQ2\KnpY1IhTeP,4`VY5+F^Ckl^(]A?/+f0Xqet\6/>#.mm36*
:^S'*-3i_Hj2rB"rrsaNL0#CFb'rik3_I7hTbTo.(b_N=M[5[_^BoO9>mEJSD,3tpQ-8soO[
,Z$$&I+,"<dO^CjKjrC]A8Q)fZFWe[o@7,rbca']AXSZF(*EG]A3d5rN+IXB>#b/W11[(o!n\]A_
3MT)U['ZHO4(MX4b5/$AC(?s#U6I=q``\#X<k;ahHWLo^s[5N!3SZDJ`s)tXj=;lX"a(5TBX
$?WAHOpr9pQ"b%p::HQ(*M(7/^A`+SS>_C6U<^\Md?<F!VMtg3)J3ni*>E.]A[T'H'9]Ao4'^A
9%*YajZN?+k18Pko?EZA0^G7@B3.M,UlU\g]AX7gfAacX&ufO))"*Ir)SuGNi_k0G+3_>C*'g
4r]A=2>p\>1ej_jg@=h:/5fZ(%Ue,%:_J%+[BS`->caX?-Fr510]Ap>RR"k3bQKT\K0"ZR%-?S
\48k]A/_U"?R"9@-NID+2.ksp9ResU?P9mHk%9(Sfq"?#^:H0Jli#E^"`X,mHiUPD[.CjlbLo
F$\;Gfohg2_1]AZ&&+csN9ppX5b#p"gX[`4T\14T@N<gZRcQ'6h'H&A-$JO5G7H23t5!FMFl[
P(m+XD[-Q+afe^[%%`QF<OZ,%/g)sH^Od$h%cCg8#%7'qJTLKl@Y7hI,+eZ<esPH<ooN\T;2
;)0Y^O07V's\L>8<McoH!?c)SNU@\3FRIk7qN_O,[hHZ/hB8CJHI:SAbuN`p?d1m*@^t,]A(O
TnKmBoQ48q4]AqJToV0E/2%$Z(Y`N#UiqrK:U?Zbb!kTsQfg`L9j1+flJ%9RqGl(0Q.>fjM@:
LCS9GY%86FF:%\Z+OM-n\-Fkoh>U'TXk]AEe"6b+C!40X]AtL-)]AH7*?V9.uC\1d+?:4-D#+f)
Vm\bAEqXp912H[5,FM![/Gj>l,W+M[\eWA`<b>s`Q$k%XYa,"g^;ZdMG<-:!r%F#D6=p%FMb
#bu4bZ*=.rL)gYr!<LPlR+_9u+Q.<q"mism=N+lE^P-),j66"T"CI26nujH=S!YQ5)>mk/l7
)*"C6s4+^pa&#)#)A[;cR3u\taR@0BqXL)r978Q!&\0EccHrW'(,O8O&4R0;[VVHs:Ru68`*
3%J3;o#ZNu(J$=QFZaPuk^E_!hDEDM,#0B2WJ2ra?F7h]A-rnAk.KiLj>Vs8)t5ioILUVYK+H
H]A$rFlLSH%GLF5Ln)cY,Q0`cGGNR3P'UB0)?.m!BY)(>aE5QfnB2rk]A"jFfZ@,`+`?+s=\O?
9_0Id%DJhQbs8:CC`;hKg`@*9liZ^Me>2Fb9KEO\f.IchG&_#\<OMs06cI,(.#e4-eD)=b_3
/Tl"-A!0f)a'H^FC5*F]A-)EF=Ci73-%\Acc*[kR%.n;\HNa0mS4DI/V\b^TM1ik$hc/R*HD=
((Pc'WYh0^,XMVJed]A6su!H'rc,(;C=t*R^DRT9lBl:;,nf1a59h8oKf:GfkEm%?rK@9FJ3D
A%oa-qH>lg!4GMk2B`1F1^;-ZkocBL\e;;SV_4CIjYH2H?2f_g7"cR2hnTC5A=?cHImD=uU9
@.;@F-^!I<`62u+J#k9)#6/gl\VJnrOtgj]A<1j5Z*9FPFD8d^.m$0H__1_@>-p&Bg4<$kgja
D!ghanC]A93N;]AP.5foE(>V-W1V-53Rc)Hf#'H<RV-<q[goXCUYeTFQM%FLdfV53R%pu>^k;u
>.a^X^i*2#<u4tj!Xm'49-Y)oHAp@Bj_ps+&/2b\N8Vf@kf]AmeF<Q:)+<H=>\i6Tp!srTb3I
]A7cXAm&VdFmj:GBQd$55+E=QeG;%l@SleUL@K[2VKelZ[VA(iCd0^Im`jmR%T8nB/WRcHqJk
\54a&!="^^`H9AX\&#>Iu'RcZV/lEXZ>s?(#4#@;Z289tV119%G5g_bp+^u:FdX[mJIB9qRj
_3lm2)W:,r=*XG?Hpn7V$>GZ#8%o?<_^_tNY-:dOu.iC![M7MT&n9pTI*siJpoKcTim4\lBj
PE?>1&n9/^1fZ..KAh!<+.K$nd(^!EK^cCmor(kXaC4.!R4eE4&#B]A\jP8V$(d0WjZt]AU#'.
]ADq0/p2j9GnF?7:JAjh'J8P9GHG4W7hdp(2or'sAZ'%&Wi<tU1(l='b@\6LpfkMS"j*kYn9-
e\p6Fhh\ACX@(^nq;P'2BA9T8H4S3.`T\$hI05`^9R[4EQ^"rIHg[U:k-el>5Pt(iFZAU$jK
Q^&FrJ)[m/l\8.ENeiD7p0ZDF<2QS>5lZ:XW1Ek&Tdpba82UPGJ)L>^7Bse+3M>HRR0Fs(lP
FEh_D&<#`i)1d8GbG-JOl)a4II5b7e_mU;e8[/rl:I-casZIa]AkID"B&Ruq=5p2HcuR%pPZ4
oQ'mclp:mF?,&lt?mes__H<J_(dgkhQ<TmkS;RA;$l"1ZKLS*%F=G,>4+G!DuiAgLaX$9*<=
_&@"X??0k<Ea?o\mgmp6KJ>>KAS299J58l2P!=\D)9<BnC?2(;=h3G%?Ol/-q4,ANpP6MWad
mBR'\(#A%7an!;6`&=KVnPY_>>MEZ;@m1JBrLt9Ekgcf*LN[RuG@hogF.dDQ''Imqsfre"Zl
lmS'KX;VF\hlU,o<!D"Y)b:S"UWeVft`Nh3CWC9@E'VIGj6j'_6\:n2kolDukNdn?7/[Q#G<
^^]ALqSLa4r9#%Z0f1%I23<SVhm(!BFT724265n`@_sQK@]AFlX2LRheMpfNM(2FB-S5+29T%&
EN)fr3jfI(Q(9`1@U?C&1Om'LBL$K,EDbQ*CI6l7)>)eCJ%?+ZqO1:,5Z;;BK$fOJ<)4h*:B
'-NM?YD,*`YdBN.KS+HBbnI)F4]A-Upf4TgLZjiH'V8=="E$.aTVL5,K'.F?UUQH3:&Df,c\g
TXFafaEOnJgV@\Z4c4C!5GLC**a%!VoOPJfFq+m6-^Bj2#TM-%WneL;LpHQ[<25Bd(jI":.U
m7D5mhHsS_!^#V-Sa1[nb9cr&(anoL$7:Rb%B^)!,V*+EOKOG9]Apg\fY^JuQiA$,oe'I3Odp
^I]AK*@gHSl6Nl2SK8P";_@tDCm7%4:]AZ`/&GcR))sD^,9_Cr`R$Yt.k6K4M;9GWVKct^WF+^
,_85.,VV,1uL8:Z.&_Me6N5l&I\Ti:KbF-0NMWl(aJ='3d&[>B?(.D.<%/M8BA/pN(g)C%Ar
^SgqO!Peb#jmA\`q;\rfC9\eBlpC&S4$H%!Nf`?>ac35A[q`TCdMJB3T4He*nqFof('C]A)=@
=<k^mL4XZI'=Be5:?jm0mJR8*<c,'6p!0IlrQ9V9%7>3kV++afXK'.qM@!Wu=Q&qpJ5$)A,W
HYDZ3+Q'5,$/J(FPVm[>WW210\oo5\K4%91n5;[lRA6CP4eHu"r]Ai%OWj,ZbU%W+aKP+f>$o
i,*!a,CS]A2i'K2DbBa/JNI1/WLUp^"L10jcfn(.\D!UkF@#mHQ_c)h<NB-K/!k7V<8/^6;tR
c>pTIS+!RGZA_M7PYN>M;8e.ct)1ea7N1"[ifGRpM%Hgc7;<q\j(hcgMJZO6jBk3=oOO9I\J
Dc5W:@Y.H"Q7QYH2<%?ogQR&df&"G2.dHZl#0R]A4cRs*rd@27JlU\XJ`l^91bfA3Yi(,@Ca<
FoERkCfLJa'^6V378(g_,+T!QnlI":>s:/3gPOOC\=/8\jSD!BAa!/fCq0e>+!p@HT\LeM5Q
180IFsSt_&&)-pGU[ii^GZrS6+,6c?;f8pl7><('?21LJTQf:;h^)*Ble>q.MjtFJMl<e37C
7>Y"G%]Afag]AE;*8JHK0aej%J%u[Hi\neE_m.a0'#YHTs(^2L'gE,/5T#t#CUrM<c)^7@Ae-M
eG7TP=__N9a($LG82`"EhPI9\)JB:m]AUQ3"iMJn+Paj^^-[A[J9e,#:ZH%%R!^Dd98:k_kTK
FehXq22uAXWg.*4I1mdS["5&K_p74,2tUh/bf#\;j]AN9rXl[]A6&Vm,pJ67[g$@0oRTu'lH\p
*U=c-PbDFtXr`cf9$Q:kS(E@RGaknU9,B.J79q[%7jpfq/:4@qF0eHajb)dVWDe*G1b[8d&T
,4eSjQ9i*C5k$JOa+lgSh7lF5p.WB>pK'`$Z-!<0.Ui[YFQOL[VnA;D[$1ChYNt?iLIu]A>67
V<]AjSo=KP1N?C98W9rtD7rsd=WWi?]Ae8uQ1GX`q9PU[9DZYROgakh\g?tnJI=n*>6U%mGSG=
[-9F-h.'Kn7#H1-(EBNdiiIT\uDD&\hpC]A%<ST=1<=R(lQY/Eo-33@@T_(PeiBm(5HH^W,Lj
k/p^M:X^$Ccr>)p!^DUKA3.-nSUQFlmP59!4R_EH+S<B;W&V%YVe<Zc62KU;'ktsbhc5D,pQ
]APGp_5S5#p\TZroc7u9I'WK&Y("9c9?Ms9jN.\4:R?[-uE5R#eN&INJF8^r?%E1XrL(oMZ-=
T+DsQm&qVbqE;XbL:>ML-m"Or-L%(n%n1<;0fcPjhZ@hEVKA!O8+/U82*P=Yf8j`s@,6U%"M
*omOD7ZF!@spnBQ<e#a`*3kNOC+t\m&:>m8ng=j%8R*#*AOk[,>%-"`snG6\-3O#"ELS@nH$
i%ZQrFDn&qQE7LmQkk<&b+g-]A2Eb;,Oc&UioH(psjO?5:kO(?j#WD>*.L<78n!B\"G/>^`-h
qXSs!R;_?7gm_JdnW`$el9\p(8"-R!N>mkDZ8F:**nMIX,8ss!TLU7`-EgA#fFaqXF$bsKG5
CC?E4&pY./F:V2IrCW`&ND,rimiUa5_)A\c:=2:DIH)@i7d8V\<7]A9:B@,Xb\D-@WlK[C(.`
l)Wb1FSn?.+.0W?VWl<M1K8-?E@>=4+mu`cl54a3;(e&G>EI:?FhaaW"X?m7sdi`\*L<tgZe
fG=e/@>6>9J=?jR.$W:M@>-O7E`G@]ATXd*TWX&!;;p\o&`XbFUcQS+f$^-[l-u6[c3N=A5,`
4BeUg<=1i!c$@?=("'P4epg%AOfV@urt6GT$]A&5R>=V#tH+6:pFjRlN3?Vj-J_b>r8s`(>bt
MmH#X1mUt;Q]AhaH7,G7E7dAY[GW,c6!chQ(5V.&2!4MOi?R)@>9CKQa8S]ANL7rY&W_o)BS1E
.33<`P-H`@qEYY36k"\aH0<Q@@Zj8V/C0+fHHgJ0HPUU?W7aRrHG'C0&'gN*Rhi*X:7_GSjG
*S6gH/"hJY#\jEUdhX@IHNi.Lme15l+0OY+`'9;,aY*q/o4\R4q8qUkJ5:hamN$0#f6TOgOD
2YC]AkGMaA1!a_hjdWn4Z^'bX:rT>Q??aq+s3r&$QGP)>0/nid>o_K(.@!Wj]Ai#>=1SuOq>TA
,3.@".cW$I:#a7_@MJp&*O'Z9$f1c1W*5$1&j%h--MXD?sg3opM#8`rM'_`OWO[HT5\&d)(i
R]A9Q3=\-Kt#VcA+Te^GsZJVep_ZHsE"i&(LlZ+@]AKH08M`Qj;4gN3.)N(7I+F^PY7l;q>#Tu
*`XBG\>8(a@@ms%SuNVu`ub[=@p=h@\A.BsI:CM]A-YmRf--\6F1nSW'osi8t9oOL10,1!p9P
`cfA$7dD<9?Jq<//4rG0$X.@_s+hkBpiLV.DY5QYdDC8S9G3+$/E;pusD7k@0VbH5MO'[HZ?
-=hHiS#&/32KsiJTa,2JB,OGVft=#N/s4=Bf:*BW+]Aj#G#,QRbqWP@fj,t5/M(,H+Hc[%+Cj
+.P:lrgrlbPkmPhuMr5_/^n)A'#@A)FReS#8_o)(Ub=IM98jac27le.HA2i^A>R-lPWC<Yj7
^Bod9[Lo#Wl]A35aCr2i\@]ApD))`U=RcFW]A5"DA!`L:S&1dHW]Ab['=%2;'R;qY\D$<EHt,E/[
EMnk#>iqX_khmB-@368gW7iN^_HT7roMT>iB*qe=s.2`Z5GaeZ%[8hOsKKEE2!6I61BR;56J
p#Xa?F[N!f`DP`5:d4@&QE02]Ar:*pj*0fg*BVp4<6>"JGDAu[X`,t1=pJ2c.T3+\V]A\8EJDn
^.3@<-PaO8WUa<,]Asd&i^2Q1?Q`@'#?8D9DM&3bpfagU\XVNn!L8<.-ahDn>Lu>:<HmD!TC"
8kReuJqFQc"3M%XdcS2S93X?9%R$Y3PP^Tk.LjFdFL5+ARMq$PiZ]A<0c8^$fqp_3[A'V)R,3
QB?Q.#hu(/J=q>ORi2m-Tl=1N;N`NRQekWk%=%+rC=%ic^l#t.FY?8b>BKJ[`N+>\)Dn"0[@
FPGZ!4T&m)&AqC.r]A^n*h'd_C<ajcOklC,M^%S@R^AAdVXen$*RZd"17X]ARNT*s`Sd&:XOh4
K%:&#$Qh(a,>Lb@NXW2[j$,i"$S)\Vp.-'jNS_60@W!-68R.Cd;-\RU["qMsC0`$7/lY*Sf<
#J:n^:Xm0e6eB=>QIF`-6eA6,a#Xlhp%"Ueec,<GuCbrGb#?M#u8^[<.:XCf=m>CQ.0o$`8"
Z=_5/RgfO^]A<2BZg'Y,,8XAV0%;YMqlSleXe\d:SHj]A0T`iAdNliK6e9T3R4S==Qu83+nd8h
W$#AS)I6*kB/Ug:2Y*^C8Y2;!$uHh<;/m)e#c1Pu;dY;'WFlo&&]A_rj""QSZ[dj2o]Ap`03ME
@ktHV,o+.hDNe4B5W8dSYJQ=`oeBL(1W:PFM0r3Ni>M=j5P$,-6jV5HQ?^p\t$l]A-/]A$<&rt
@S56!0"Ll:nJWHYZ0NcCG,)q#SQhk2TC45''U6s>:<T=p%bS[`;@*JEZ)q,XrhpM#TftXAec
4X[KbHPoBk!BM"a/th=@^bJ)^)2N9-3]A"GcXf"[6;n'Ifg9"KYH5.;!K*m$Z3VfFURhj_B,Q
%#<*Dq$e<IFnHOog`=V:upJ\AeUEQ,L]AAE<fpn]AI%aFbj6E7Bh69rM^0Cpg+'kCrn4hA3N\&
+9ng(WD@?"Z()\6&W9R8*)'`+MRc&_?l1aEni4TNT/D]AjQ2DS`U0L0h1tm[oBAg9LQ#gHlWP
i"D\KHsqfNGB8C(H<;d5>:[4>Ugca[e$@hOe><*8;`fe=I7H/g3L[2#a.Z:F2d-hR.2$_<"R
&`s&Hk77-gi,E)@uVbr'$HA-[h\Mg1Ed7mO)?(R>$H2kC=WF1P6ggo\^f75/Vf*4mFAg!)"`
6X@mTX\+PQeQckfiYkHZVH*r'=(g!lYnYJeSV4im^ChG,#`t9`GF<J=agNE'DI9)`QOQQ9P9
6>lQ8]AGUTNDH9T2rSPk-hk#`;(,+ll^ESYGAGX%:"Zcj,)7]Ag6*ZZS@M^*(X@r&.tMm^>T1j
=$oGRdmu=Tm/@d#QF*Vk[A?s4dE$)H.W6FZC3f"RAGjTWMgn<6;ipDm#nu==gL9a$e\2XRo#
oD.j1nNK'm0U%?dVDB)hN%bKIEIq;]AP[V3c<St*U'qORd7?&gJ=aUhn"\FX!t;mIrq>`*S&/
;h[`F"D(ZgY_9<NX1"oc+72]AWepo/0X5p?6CFE4TL)o(`X(M">8FuOB0R)fL4:hOF(e[,2'Q
gU8FPc%U@^2OZ6RnX8=MTW0p.?O6@k.BD"7Co@=/,!Geg=GO[E1)?)-1S#,6:5&X)NtgUK,O
hTWCZ7se)@UO4Ge3+)E:*6bLef8^+oDJ0R.%'WbH`[/G$O'+cQd*KoOB`E>kZcPOb_:`M\l@
9`=e<dsB/9Q$:pNBhG[9M$-8a`XdI!C&!67C-9CLK@)N0T#8sio)fYLfi3VJ%4lT[M092\7h
OD_^ZJ0>LS[5-Q<u(!08k)@,ZX6CV!<VK>)i"\R)N\=d"2R8^/Yb6)V78H8Eq7`C5V0@O!qu
j!-uj+MomBW%#]A'A)EpjWpI?E$@Caki$6J^lF4:#2!dU'1Hp$Gp-K4Hq*]A\+7BqcI(4PYP%0
W4).@ZIhVcV:k3r\YJ=i'D<NeP4Ne)c=O#?j?InO`=_B(lF'/Kj[AQ+X2Vd*ATaN)\cK>7:-
&kSXS-"SuXO2Lm6/X0@[QIWJB12dYO[5b@(04ru'4leV#`18Cao]AS+n_QqeL9fQH"/$+\40d
M+rJBV*It_c_OL0m-Y4oYECcDh3.<ln#kC#=baA=f3<'t/2ltb7REXK^ElChZYkR?7((Lna;
RNKE[N:nh%@k7drNncW3q2Okb\1?^9&e%TT6d84s#8E'piJPZ8'qSFTusT&.$iQC'i3I)fO-
PKJHY:o[4`^^+\KMhu(<_%<?j4imq)]AjG('Z_Bd%cg3Rpoju(3*0:;?b^FjA6==oa#&@I)Zq
'@)b75Rm;!qfe1oj/QEK5C<X=[K`pQqH&]APS+"BR1)l*oNu?732Ue!L]AFoS#Eln7R,Z<I[#b
I1Ymd#kOehj'5bVS%%L]Agh?aGo]AW#uFs@:RS0A*)4K5aWlB1Zc!_8sT%u!V<i\s,r4kV(TrK
c]A,gk-mWqB!qQi.k8dsF,en&Nd^sSA7,LmRcA2AGrOTd"dA%R6W\Plm8]AG+mEaQ7+2EXRr$@
-i2-S)QK#kdN0e;F\uqeD08AZs")))JEQ2ls(YNI/FC58:;qKI8T_a^$ItKWFbP6=B<Kr\dH
PPgOQq=G)i8AdL8%5'MpTe#\GU]AVH3Q3VU)PWUUe52gk8'kW3hK)[saDbs,TrYB?4uc356uo
bL,$q@Hfd[HkoL6RHX>Khl*0&[Nim?_1VaVo3@UHRd[RH+t@'U+&$UbEamQ\I7WKT=<E*(bK
kJ<ctt+P]A*[JG!B(4+>pNto`eN(:*L'W4o]Ad!YaW2Y')9Tb+cG0KZ"`P'XWKp&2gB6ZQTNnD
*FI=P?g/-Y*9=YD57+hAHlV8GjagTd&:#FjcmOr4MOG5L0i1-k:Qf8>2YQL-e4MG4<0j2e+K
)N,k#1-jB_@)29m?at/N1`n4*?@sF=$&<V-i`bR,hSfG2<W=f(6B?9UBBYPg+\]Allfe]AQDYr
`IW2Qs!.&`%A:e2q[X:FhUqF-E;,+A\fYn6O?L`Brj>B>GP;rR:GMbM_cC2Bc]All]AS/ZBA/I
4hD;)QDj:B`D[>/S.]ASbtP7,AlJtaV4=DgcJ8*Aa?03^8C5IBrUe`]A:7j.bARR-/Qo`MhYDI
q^+"5Ln_@fA<FDR,^i0ab$'"lIGfn;-1$A1O\,Rb"j.P78HO\KWZ[Yl-i*eD>M;p>r?E,=8#
i:eLoc=MWkS:QW>Gd:S%VFkj>/?+FsWlQ5(*K%L/$NF-V2(aS^np@)o]Ar_il#a9.VF%AaPnA
ZCDK3f#;?YG%pMp[SrC_-\QG9%BMT1'2&On5i>ps0()rUG?MeiYbpM9NL27&k4]Akd'R\N?<;
G_%rsk9ii9fHk8tVC"Gs9(#:FBgE2\[jQi%oFt=#l6]A3O+$_7q%/W*J,dBhpqVi#<cVr+l4M
C\22e/m[O*otkmb:Ioo@c-=%_?k,jP'/`#h_j^j_#jhd:]A^(YKPmsY@*sTR`Z9IZK/B1^r!Q
7G<WS<mFPfoPQ:RdjcbO;fpU^-Gcc=RNZ@>W.q4_a=q!L&jd!sM=CB_8s[(=.4rV/K9k,X!I
@<kD5]A-gF:JpuTmA2%]A$JQQ38>CBs,(agM0X5mUZj*pWtNdt&=2bCCl!j<T:U>A8$CAFd1S/
r+6lV8he+8:>4MgIhr&g]A5^KIDi-LVg]AYFL;5tm3uZRhTYeWN8AX.Rbn8E6O2fV`]AC#+d$cm
$Bh9FX>s.!KX`i:;hqe2fHSk;q*5NsdI;1\UISZ$KR7,B4^b<54>7a,)jBU""DjGZkaUHo.7
A%X7m(JM\%)/NtE(uM88kPfp!0XNY1^p#b,gaIc$Glskr&B[/6hu;7]A;r_VZ)coiHd=l5WTs
td$=5L86L0WH80?54"cmK;LmXQ$Mtk1bA)rd"+oukk)QK]Ae(<J[_UV+3=j/Q*&a"E#EcIcnL
iH<:]A2$@Ht`-ZWoJ+^n!#sK;sML1/C^]A>rW&1S"]A8#QH6GO$4a(%R4&eEFJ7X[dlgciB3*o6
Jk&RNl2D6^J37V=?qas7gmYKW(5,6O8@HI-;MqF3lK)\+,;'SLmtR+04h__p?NPmcmN%0`Jb
Mf85<1Jtiu#%h$7R5Q"8tr8d!##*/1U:/V3iOVa#kJnKRf)NaP$_HZs*+t4)h.<>+&+b!1N$
/TQH]A7TJ3JGmh__]A2?E"!KUer@q?r9"!Ab-Ag)g\a'3?k]A:hl3GUs)>ebKd2=l,s7K1b;L--
-^j;<7:1tD1;)'B';UL&*)#n_o(k2[&%]A1=(TcqI>NghCh?-.[Qc<X5CH`q.Ral+($CYhf#G
5mI68A2>MI)L%XK<\F)8FX(m9Fq]AI0$PP=Ul[G;:R=;XQ"8@?K;6NSE5;<*sqZPU8A2R\*Q1
"PCo`.EkIT?d>qYqW~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FileAttrErrorMarker-Refresh class="com.fr.base.io.FileAttrErrorMarker" plugin-version="1.5.4" oriClass="com.fr.plugin.reportRefresh.ReportExtraRefreshAttr" pluginID="com.fr.plugin.reportRefresh.v11">
<Refresh customClass="false" interval="0.0" state="0"/>
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
<![CDATA[1143000,723900,723900,304800,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[1440000,4032000,1440000,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0" cs="3" s="0">
<O t="DSColumn">
<Attributes dsName="日维度销售额" columnName="总金额"/>
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
<C c="0" r="1">
<PrivilegeControl/>
<Expand/>
</C>
<C c="1" r="1" s="1">
<O>
<![CDATA[昨日累计销售额]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="2" r="1">
<PrivilegeControl/>
<Expand/>
</C>
<C c="0" r="4">
<PrivilegeControl/>
<Expand/>
</C>
<C c="1" r="4">
<PrivilegeControl/>
<Expand/>
</C>
<C c="2" r="4">
<PrivilegeControl/>
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
<StyleList>
<Style horizontal_alignment="0" imageLayout="1">
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="4">
<![CDATA[#,##0.00]]></Format>
<FRFont name="微软雅黑" style="1" size="104">
<foreground>
<FineColor color="-3409409" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
<Style horizontal_alignment="0" imageLayout="1">
<FRFont name="微软雅黑" style="0" size="96">
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
<![CDATA[m@%fi;qJIu\b0'/n^6VMW!'[)P_u:_H9m-,TiM>BMolut#S^)Xb#8pDg<tio888E>$m?>gPQ
677#ne@a'TA0ML]APC?M$O\b#a%UiaRaqqom"Ltj*nQ]Ac8^GplaQ$/CX4liRf>PFgAB#IJ'[e
'\#hMD1L'<jo^HiVZdlKrAugMIqJ`D=]A8C-9AnFR-3dgGX`Ngp)Wb$,(_;5PISXpg:C92L1j
)cP]AnF8(/<q`]A0&9CS]ATgW!N%i;WM*VM[/dCme+qrRcm\^"pXgpV":O$EPWgF\KU;k(G2Nuj
g\biV&kfJ"YDQqH*eU#E6b;\/Jh2'_DKGdWR(eMjo)oi*^hgmB9)gU?0tfopu>+)I&5A1b]A5
nR8UeXO:g^H*?68^<ToF\CCF?)rTF%[`OcAq*iibWF<DTl7`83fXgX;jJG+p\62JqnQs^Y23
uH_oa<rlp'7]Ah-0Wf(H3R*6h"Vf5es=u"K:d'JTF>)A'g]Aj+!7FZN;#jJ@&-IlI2)>r31-#K
5ZNiQ_&(qbn2P=t4j&OpSP?IaW]A52-tG_C5&91G8T\14CN0nG(K7SZZF!]ARgcf#!'G@sbLom
RVXs;-nq)</pch-\FC(38\B=E%X3$+Ml9C60t=uP-acA1s$VD-'2kO-Tr%HO3O(e0_?!V*ZS
2sQ!hqeZ"Fl\H>o]A)8!uX!nS<$(%V06%?LiuLPJWl/A?%5'.\V9Jm_0gf`a2h/JSC"c^9FY[
E+gFD5T!/>mpm%*!d8s1^@/,J[S@7#9N0M1;3@FqFS7=5NDF'`hU^62FoOues4Nfs+bd_Aan
@rbB(.:<<\]A%oQ\_:[l,!l#'D"%#$F>Z=JAL='J)N'A\7cWD7S-C\jV-5]AX\e.-(la.]AoTb!
4H6O_9g`kJDbQOLU16dmJfZu%fLJGi:2\d?q]A?QNg&5u-3j#=?jdmf,^h`>Zh\?`YmblAL[a
G1t8?ZXfZ1_NJpjXoh0p-r>WH_-++=k>2`fQr%O]AH_sl5^N9TR4%WY(2p[\7Ls]AhB76lO&e&
20#e7HA8hTq4!k+[,2@frmgRD9l!-!>nYb4*rb]A#lk1F3FC*(`NnI\Q'^q*@q'Tah<EiB,<D
%.cLpf6[Jd)@=)*n)CCf;`5EmgDPdm)34Rrd"ksSenHnTS2:MV6^/r`n@Ag/.HJ#OHHkZsNA
d'aQF9B=Xn/)Fao+Q&ZJ.`1NPo)<05o`.7M$_5CLMAUacCV'^D^,%>#."_''OMnbu=cg5b:\
D3*V]AG-B\R-*i!p@@s!U6V_lo4-LGrNC9`!oaE_"!98Xn7>uB_al^imcp83Y\PpGQ9Z;TW*j
Dj\_LHr%MSX+CE0*9>o2DY6]AbKi+bku$>#%Sd-n)kZn.pf_s'9m2=&EtAfB.e.L4jU$9Ugb&
FK\)bn;0;gbR=Q"0>qphNd+"t19)hIk82Sd=rC=I'2=!A*WPIdIt"4#Sa*St)bf9F#&I\QH#
rV=ZcMc]A7D`\,H+OiqQp2"sO\cM7m4X?Hn$,-2dH#%q<gYop4'7')WId1>i-Wsl=jYlDSYYV
?OfAlmK,e>on*J[<;"UVgK'poJhCU]Am!0WTKGQcA1nu,q#iO4"oW@>Ii:GYGCf>+uX5his@5
d:#=h<U[?BB)eZHBM^)<d4QPTk!A%$s6=q8f>20MYJ+Rl2$-\mt3#2E!l,J@&Spiif6J9Wp1
S4S^QlkN45]Aufi%grbYa\^J-%/a5>O&3-+/^d8c-FZShi#7gY#L?0;PrBJA%hXNo63YV<Wjn
p=pdH^(iKr=t$=lof+2=Y`PpGaqdWWd?VVoKVTrs$&Y\**io#UM@(EWsPfS@0>e0:oXBV^@<
jMg,UZK*Jpr7L%S+Or_.VPRO,+lJ<IJZGL\)5'Wo;U6gh_+a/YQCkeJ_<O/jT<[t)*359jOb
t;9NrU)t:QIGl.bu=Q7/K$>#5-UF-U=oH$^EBN+40V6d)?g`dG:OPQJ:*?Vf^K0UPe:YS/0>
1n9GdRBn-[Y01'[/I`dB"eu?FF8H$(X3b&eC2`[J;=+TIF%%eAS8WN.X/*ke<(fbqL$V)/r-
rmtrj(j5EB:ejF@a!jbq4UT.F\Vbsb-J0\%$S6[MXbZq(]Ah7BM<_.GgK1gI]A\T_BJJAen!4f
Dn`Zfa`HgG%4#+$M^@;b6eoAQ=o.\$GoP.]AONi^(Yri3$U*LE)=tShZ!^L7=(EHhtPcnR]A@E
8SXW<=A63k95_`DL2Rg%!ZL)Xk8W[kZ<M(Wa@`9%JI_.,ISNbb]AEtToSV5dg0%F6elb*;(c'
MtmiFq3B5)YRB[a!f,_tl?/e8>C%3d7_<Op=4g[^i3Vl?p'1"VS\'nH(4b6`BMjno+g&1b)`
Pf9GRna9m?)G-=1A(Q[^j.bNU9b\3:CiGFMeMMQLGiM4YVS#]A[Q/0k&M,WH4`&k*U8$lWF5,
Nk\jYG#g<`Pamb1g(P'_:(]A`J[8.5_k+,mK<#%&a[n/uQL[.2202;R!p5Gdr=!`,/eJ]AY^/)
rT=,o4QhTN]A4iFP-Ui5a6h"1\qoTt\GM9PWXr"#nRQ>c+KX?iijCC[jKLr*iu;e2m>/;"V@:
Vd:DLf4/bB58HjKOt,BrPmk71jZhH*V]A/%:q4.6`/$#P3MgQaMa:<*3gkI$h`eR;[%<@qoo7
c0gpo%U_Dh]Adi#5/G0#(+T!9pr?`&kMA;Yont)@b'T4,J4md/uhtC2&sl&2S;tH.sBV/1T3'
=o%hV7OtIfukACN9.-9H)%gFS-<2^j-eSUN2l:*[tUiPfSSs%OBir\IfR?aSBa[:"#D\4Z7&
b.5i^PZ)FhCt8Q\S)o*SNZq"JM,5tX$^'7^X>i8g!:M+A$V$!-%fjMf3V/^23&U96[k!$k'l
VWG0D:;5gLWJDd#7kh,uL-f<VUhbd2s.cZM>;_K`\edQsbq=Ijr^S^*J$UGP0OI4MecIAKk3
\D9h3h+rT^A?]AJ*"KT=;&1_<;J9<&fq/`lCT3.rUlp2od,79VuD2+JHqn[Y^d6'qeX2*4)jt
oKenm/h\3*8,Je%#I^R]A/-boDLlYp/39hbLMiF/F'bi`_<)RZ+THm/q?JLHE3FV1*9r).,'%
Wauc$O%qJ\[d6qBm[)@Xg(^P@le!e[gVsK0m)]AYhrlqr77Z,.f-2\NQI+A1B.#f+aQ8-@NHL
qrRoI$8e4,sLC^HJ,/ohsl!RT(#S(nn,U2h-ip)*$+;%,&6U/2^^+4=n;p#SB?eT1<r_=e#,
=FJN!9k:N8.2UMCIuiHhQN&*uC!,Z<38M4u%pNTe`:`a\,(RNDuj6SP7d^AMHU02B,MX7+3d
\3Vd*GU1lhcVLF-QXU$H;;7(Md'_WhRXXR+8]A.O3p+;#GjI@b3h,G=Nk2#XT12o,Z#(N_<8P
0<<;luIJKSWMNe5k0`/8i4s[`Y?oR>Zd)%dQIGN$/mN<NT_##ZHKBYC/EF?cjfm@[iIYIOPh
KD3j'BlTcQ9hC($g_c_22fjsj?Q$J`:[NRG6Q"ToGSYk^$:a7Y&H&Q<?>,qm`r2pN>[--ZH<
k1[F'*g'!F5j&;f7lesY9S7+T$"b\oN18kO"r)[1-Lm<%Q<;5OraBOfar9M"HbYgl`SC0J?]A
40A;^uo[G+KU%>3[UG/BKuW=q%gI1DQj]AmLDQ#Ym`PEH`ME,0fT)lpXo@P\Tm1EL(h.hbdgG
e#AlE6n=6Lp(&j>4c#.$k2k(,2i==DJ,+iFP$IkI?+oI`o'<%MWb(QCfl;aZaNKkDF_Do3Fj
,",gPoG-`OXk*ZPMD6WtDCIc,C9UV(/>7GIu%&-iU\6[O4mc0?(_%4C08%Zf7N>E3AZELN9Q
mU5ib<Cc#K?6Fu,FbWXt<FdM^PJ]AQ]Au93pG"&n2UE+Ps\M4L^V>/>8$VhZpDle$`I5Y;A87&
?i``4H70^EmSH34L<rm0fBNN@lausCGb^s/Y-RY%+ZL:DTF\NQLEh!q3qV%1?LVY.3hULBA^
POgs-os/UUAk*Pe1JOGO)XbUjHR2NCtT)ju%2j1),1B+QdR1XC&Y3'i:']AA:QpPtc\((=i+*
2FqYM*Dfh?g?6.TCj!uFPPn6X`H2dp[*ulgL1BY#7CYU'OtV4I#UX6eMYZL^185o=I*hM<N%
V`fEAf^i7m;ahbk(dZp[fq\AUi!HiYsFt@"M0[.Na?F/C(*o7["8B<s*BQ=#!jn\54:e\*d(
MC)sijG,PQP3R`b$j$_Dp.OtL>,\0`r>r60HX66uY>AmW!8b[Q(>_oW)ru/\B-Vo`@aZD!#T
lXWoqHt:QUm%7E*<Pr*8DX*uCbi0Oj+B&TG&BanT3%W%bpYa%2^t/$69Wi,#'XUn)0GpZS6V
Dl'rajg<.5]A@bWuo+od"h;nd)EbNri8Q#m2,s=C\r3S8UDSFc+]A3:.JosWp.ZK4bou*WKpnH
)D>HoT,t]ApY*_mh*+_2(Q6L!aIPm+tCKW+$)>O;D>6A^io&*EED+O*HgUbM7me,RLDY3W6eX
/T>C^PCPC_s:O`9a##k`\\9KJEu/i[i^]A\LLutQa#QWGO!^8J-drTAfNYl>6UV+=i$950B5J
mA_^>saE7Tpk7?!<MP_gV0\s.LAabm;HK4ME_K`)f+j@'.J#2iK?('e>.Ljr/UQ!Vb/'<lq&
sp0)rKq$`h!Ln`V>sUA\u@9El",&BU0:iYH^%_J12rD#.k,oTfY!SN'^_n^:$!HN9MrXm,Z,
+j+Hl-+4N*J^*+U"okf4"pBhl7_/=FKZMA/=$7iY,BKLjBZ.r3b$J:kI9qiSk>P*YaALSprY
200$NAF>('X+:Q,*$d!I.j=B!]AhKg0;Y59T8*6108s$[I40FC"6r3B&M/:9g04LObZ&gcHU-
)_O9jmDBqt_H.6.UIU-_j9%%l6A.Rog46kPi#R<#,P/JcXQ=6O'<eUrrAKX?[>nS(-52f]A"U
Wj4MZZ:[6S-^kErR,[lqg3L:l)+kNSiBDSd9^N4>O:VWEPN2YW,el@(1;rUDK^t:OAd$FOVT
UeAB3?1sPKdtgj`ZTcBpj,tE)UEO'Hbf"X_U8,]A\N$Wll5n`RF\,o79,Mp2\YR,LThq<*`aY
@GekWp948/*Qn7!gIY]A"$%>nSpYIokQR&:Vc8At,N]A?^D^%%]A6@L8HWg9_cr;75GN9;?RP^M
K9]AQR(Mb%+3=9Bm67gtW50Y_[H"c`]Ah$U=C$Ei:oY2BYii!QXF$Ei:oY2BYii!TI%1pO/g^K
>B'12go]Aq#8P<mFb+fXg`_<pp]A.$mWlSGXD;GJp1S]Ai\7/\tXr.2hN*hj0<UJ#!]AX7U;LRHa
+s2,<'T)S7%~
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
<BoundsAttr x="0" y="0" width="114" height="72"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="11" y="10" width="114" height="72"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
<Sorted sorted="false"/>
<MobileWidgetList>
<Widget widgetName="report30"/>
<Widget widgetName="report30_c"/>
<Widget widgetName="report20"/>
</MobileWidgetList>
<FrozenWidgets/>
<MobileBookMarkStyle class="com.fr.form.ui.mobile.impl.DefaultMobileBookMarkStyle"/>
<WidgetScalingAttr compState="0"/>
</InnerWidget>
<BoundsAttr x="241" y="43" width="439" height="87"/>
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
<OColor>
<colvalue>
<FineColor color="-4857768" hor="-1" ver="-1"/>
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
<Attr enable="true" duration="4" followMouse="true" showMutiSeries="false" isCustom="false"/>
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
<Attr gradientType="gradual">
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
<UUID uuid="b2449328-b59c-464b-8f03-9f08bcde3998"/>
<tools hidden="false" sort="false" export="false" fullScreen="false"/>
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
<params>
<![CDATA[{}]]></params>
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
<UUID uuid="ce3de49f-a8a0-4285-8386-061b80c7506b"/>
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
<BoundsAttr x="0" y="0" width="222" height="294"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="10" y="58" width="222" height="294"/>
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
<params>
<![CDATA[{}]]></params>
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
<UUID uuid="80a07089-cb89-4b8f-9744-0d330097f4e7"/>
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
<BoundsAttr x="0" y="0" width="446" height="95"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="229" y="43" width="446" height="95"/>
</Widget>
<ShowBookmarks showBookmarks="true"/>
<Sorted sorted="false"/>
<MobileWidgetList>
<Widget widgetName="report100"/>
<Widget widgetName="report2"/>
<Widget widgetName="report6_c"/>
<Widget widgetName="report6_c_c"/>
<Widget widgetName="report3"/>
<Widget widgetName="report4_c_c_c"/>
<Widget widgetName="absolute10"/>
<Widget widgetName="report3_c_c_c"/>
<Widget widgetName="report4_c"/>
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
