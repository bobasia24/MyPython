<?xml version="1.0" encoding="UTF-8"?>
<Form xmlVersion="20211223" releaseVersion="11.0.0">
<TableDataMap>
<TableData name="月度各区域目标达成率" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[with a as (
select 
left(发货时间,7)发货时间 ,sum(实付金额) 销售额,
case 
	when `区域/组别` regexp '分销' then '分销'
	else `区域/组别`
end
区域1   from 
profit.dw_吉客云销售明细单 
where  部门  regexp '线下|分销'  
and left(发货时间,7) = date_format((CURDATE() - INTERVAL 1 DAY),'%Y-%m')  
and 渠道 not regexp '样品|赠品|dg' 
-- and 货品名称 regexp '冰粽|冰淇淋' 
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分|预付卡'
group by left(发货时间,7),区域1
) 
select 发货时间, 区域1 区域
,round(销售额/10000,2) 销售额
,round(目标额/10000,2) 目标额
,销售额/目标额 达成率
from a 
left join profit.人工导入bi线下地区目标 b
on a.区域1  = b.地区 and  a.发货时间 = b.日期
where a.区域1 is not null 
order by 销售额 desc
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
<![CDATA[select round(sum(ifnull(实付金额,0)),2)  总金额
,sum(含税单价*销量) 成本 
,(round(sum(ifnull(实付金额,0)),2)) - (sum(含税单价*销量)) as 利润  
,sum(销量) 销量
from 
profit.dw_吉客云销售明细单  
where  (部门  regexp '线下|分销|市场' or 部门 is null )  and 渠道 not regexp '赠品|dg'
and  left(发货时间,7) = date_format((CURDATE() - INTERVAL 1 DAY),'%Y-%m')  
and 渠道 not regexp '样品' 
and 货品名称 not regexp '贴纸|雨伞|不拆分|补差价']]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="月维度渠道冰粽毛利率" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[with a as (
select 
case 
	when `区域/组别` regexp '分销' then '分销'
	else `区域/组别`
end 区域
,季节性产品分类
,round((sum(含税单价*销量))/100,2) 成本
,round((sum(ifnull(实付金额,0)))/100 ,2)  金额
,(round((sum(ifnull(实付金额,0)))/100 ,2)) - (round((sum(含税单价*销量))/100,2)) 毛利
from  
profit.dw_吉客云销售明细单  
where  部门  regexp '线下|分销' 
and  left(发货时间,7) = date_format((CURDATE() - INTERVAL 1 DAY),'%Y-%m') 
and 渠道 not regexp '样品'  

and 季节性产品分类 regexp '冰粽'
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分'
group by 区域,left(发货时间,7),季节性产品分类
)

select 区域,毛利/金额  毛利率 ,季节性产品分类
 from  a  where a.区域 is not null
 group by 区域
 order by 区域 ]]></Query>
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
<![CDATA[select round(sum(ifnull(实付金额,0)),2)  总金额
,sum(含税单价*销量) 成本 
,(round(sum(ifnull(实付金额,0)),2)) - (sum(含税单价*销量)) as 利润
,sum(销量) 销量 from  
profit.dw_吉客云销售明细单  
where  (部门  regexp '线下|分销|市场' or 部门 is null )  
and 发货时间 =  DATE(DATE_SUB(CURDATE(), INTERVAL 1 DAY))  
and 渠道 not regexp '样品|赠品|dg' 
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分']]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="日维度销售贡献榜" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[
select * from 
(
select 
 case 
 	when  区域  regexp '分销' then '分销'
 	else 区域
 end  区域1,
'合计' 类型1

--  ,sum(数量*箱装系数c) 销量
 ,round(sum(实付金额),2) 金额 
 from 
profit.dw_吉客云销售明细单_下单
where   部门  regexp '线下|分销' 
and 下单时间 =  DATE(DATE_SUB(CURDATE(), INTERVAL 1 DAY)) 
and 渠道 not regexp '样品' 
and 货品名称 regexp '冰粽|冰淇淋' 
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分|预付卡'
group by 区域1,left(下单时间,7) ,类型1)asd
group by 区域1,类型1

union all 
select 
 case 
 	when  区域  regexp '分销' then '分销'
 	else 区域
 end  区域1,
case  
when 货品名称 regexp '冰粽' then 	'冰粽销售额' 
when 货品名称 regexp '冰淇淋' then 	'冰淇淋销售额' 
end 类型1

--  ,sum(数量*箱装系数c) 销量
 ,round(sum(实付金额),2) 金额 
 from 
profit.dw_吉客云销售明细单_下单
where   部门  regexp '线下|分销' 
and 下单时间 =  DATE(DATE_SUB(CURDATE(), INTERVAL 1 DAY)) 
and 渠道 not regexp '样品' 
and 货品名称 regexp '冰粽|冰淇淋' 
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分|预付卡'
group by 区域1,left(下单时间,7) ,类型1






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
<![CDATA[select round(sum(ifnull(实付金额,0)),2)  总金额
,sum(含税单价*销量) 成本 
,(round(sum(ifnull(实付金额,0)),2)) - (sum(含税单价*销量)) as 利润  
,sum(销量) 销量 from  
profit.dw_吉客云销售明细单  
where  (部门  regexp '线下|分销|市场' or 部门 is null )
and 发货时间 like '2024%'  and 渠道 not regexp '样品|赠品|dg' 
and 货品名称 not regexp '贴纸|雨伞|不拆分|补差价']]></Query>
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
select round((sum(ifnull(实付金额,0)))/10000,2) as '2024年'
,round(sum(销量 * 含税单价)/10000,2)  成本_2024
,concat(month(发货时间),'月') 月份 from  
profit.dw_吉客云销售明细单  
where  (部门  regexp '线下|分销|市场' or 部门 is null )  
and 渠道 not regexp '样品|赠品|dg' 
and 发货时间 like '2024%'
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分'
group by left(发货时间,7) 
)

select a.月份,a.2024年,(a.2024年-成本_2024) / a.2024年 利润率,b.2023年 from a join 
(select concat(month(concat(时间,'-01')),'月') 月份
,round(应收金额/10000,2)  '2023年' from 
profit.ods人工导入23年线下) b
on a.月份  = b.月份;]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="月维度渠道冰淇淋毛利率" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[with a as (
select 
case 
	when `区域/组别` regexp '分销' then '分销'
	else `区域/组别`
end 区域
,季节性产品分类
,round((sum(含税单价*销量))/100,2) 成本
,round((sum(ifnull(实付金额,0)))/100 ,2)  金额
,(round((sum(ifnull(实付金额,0)))/100 ,2)) - (round((sum(含税单价*销量))/100,2)) 毛利
from  
profit.dw_吉客云销售明细单  
where  部门  regexp '线下|分销' 
and  left(发货时间,7) = date_format((CURDATE() - INTERVAL 1 DAY),'%Y-%m') 
and 渠道 not regexp '样品'  

and 季节性产品分类 regexp '冰淇淋'
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分'
group by 区域,left(发货时间,7),季节性产品分类
)

select 区域,毛利/金额  毛利率 ,季节性产品分类
 from  a  where a.区域 is not null 
 group by 区域
 order by 区域 ]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="月度各品类销售额" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[
select round(sum(ifnull(实付金额,0)),2)  总金额 ,分类 from  
profit.dw_吉客云销售明细单 
where 分类 is not null  and 分类 != '组合'
and   部门  regexp '线下|分销'
and  left(发货时间,7) = date_format((CURDATE() - INTERVAL 1 DAY),'%Y-%m') 
and 渠道 not regexp '样品'
group by 分类]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="日维度销售贡献榜_发货时间" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[with a as (
select 
 case 
 	when  `区域/组别`  regexp '分销' then '分销'
 	else `区域/组别` 
 end   区域 ,
case  
when 货品名称 regexp '冰粽' then 	'冰粽' 
when 货品名称 regexp '冰淇淋' then 	'冰淇淋' 
end 类型1
,round((sum(ifnull(实付金额,0) )) ,2)  金额 
,sum(销量)  销量1
,货品名称,发货时间
from  profit.dw_吉客云销售明细单  
where 公司 regexp '深圳' and 部门  regexp '线下|分销' 
and 发货时间 =  DATE(DATE_SUB(CURDATE(), INTERVAL 1 DAY)) 
and 渠道 not regexp '样品' 
and 货品名称 regexp '冰粽|冰淇淋' 
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分|预付卡'
group by 区域,left(发货时间,7) ,类型1,货品名称
)

,c as (select *,销量1*箱装系数 箱装销量 from  a 
left join
(select 箱装系数,产品名称 from  profit.人工导入bi线下箱装系数 group by 产品名称) b
on a.货品名称 = b.产品名称)
select 区域,类型1,sum(金额) 金额,sum(箱装销量) 销量 from c  group by 区域,类型1]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="日维度销量贡献榜" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[
select * from 
(
select 
 case 
 	when  区域  regexp '分销' then '分销'
 	else 区域
 end  区域1,
'合计' 类型1

 ,sum(数量*箱装系数c) 销量
--  ,round(sum(实付金额),2) 金额 
 from 
profit.dw_吉客云销售明细单_下单
where   部门  regexp '线下|分销' 
and 下单时间 =  DATE(DATE_SUB(CURDATE(), INTERVAL 1 DAY)) 
and 渠道 not regexp '样品' 
and 货品名称 regexp '冰粽|冰淇淋' 
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分|预付卡'
group by 区域1,left(下单时间,7) ,类型1)asd
group by 区域1,类型1

union all 
select 
 case 
 	when  区域  regexp '分销' then '分销'
 	else 区域
 end  区域1,
case  
when 货品名称 regexp '冰粽' then 	'冰粽销量' 
when 货品名称 regexp '冰淇淋' then 	'冰淇淋销量' 
end 类型1

 ,sum(数量*箱装系数c) 销量
--  ,round(sum(实付金额),2) 金额 
 from 
profit.dw_吉客云销售明细单_下单
where   部门  regexp '线下|分销' 
and 下单时间 =  DATE(DATE_SUB(CURDATE(), INTERVAL 1 DAY)) 
and 渠道 not regexp '样品' 
and 货品名称 regexp '冰粽|冰淇淋' 
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分|预付卡'
group by 区域1,left(下单时间,7) ,类型1






]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="月维度业务员目标达成率" class="com.fr.data.impl.DBTableData">
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
where  部门  regexp '线下|分销' 
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


select 发货时间,销售人员,round(销售额/10000,2)销售额,round(目标额/10000,2) 目标额,销售额/目标额 达成率 from c left join 
(select round(目标额,2)目标额,业务员 ,日期 from profit.人工导入bi线下业务员目标) cc
on c.销售人员 = cc.业务员 and c.发货时间 = cc.日期
where cc.业务员 is not null 

union all 

select 发货时间,aa.销售人员,round(aa.销售额/10000,2) 销售额,round(目标额/10000,2) 目标额,销售额/目标额 达成率 from aa 
left join 
(select * from profit.人工导入bi分销业务员目标) aaa
on aa.销售人员 =aaa.销售人员 and  aa.发货时间 = aaa.日期
where aaa.销售人员 is not null 

order by 销售额 desc ]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="ds1" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[with a as (
-- 基础数据过滤
select 
实付金额 ,销售人员,left(下单时间,7) 下单时间7,渠道,二级部门
from  profit.dw_吉客云销售明细单_下单 d吉下 
where 一级部门  regexp '深圳线下' 
and  left(下单时间,7) =  date_format((CURDATE() - INTERVAL 1 DAY),'%Y-%m') 
and 渠道 not regexp '样品|dg'  
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分'
)
-- 清洗分销销售人员名称
,aa as (
select round(sum(实付金额) ,2) 销售额 ,二级部门,
case 
	when 销售人员 regexp '钟意珍|陈玉' then '钟意珍_陈玉' else 销售人员
end
销售人员,下单时间7 from a 
group by 下单时间7,二级部门,case 
	when 销售人员 regexp '钟意珍|陈玉' then '钟意珍_陈玉' else 销售人员
end
)

-- 按渠道匹配业务员
,b as (
select 实付金额,
case when bb.业务员 is not null then  bb.业务员 else  a.销售人员 end  
销售人员,下单时间7,渠道,二级部门 from a  left join
(select * from profit.人工导入bi线下业务员渠道关系 group by 销售渠道) bb
on substring_index(a.渠道,'-sz',1) = bb.销售渠道
where bb.业务员 is not null 
)
-- 线下业务员 聚合
,c as (
select round(sum(实付金额),2) 销售额 ,销售人员,下单时间7,二级部门 from b
group by b.销售人员,b.下单时间7,二级部门)


select sum(销售额) 销售额,sum(目标额)目标额, 二级部门,下单时间7 from  (
-- 线下业务员目标
select 下单时间7,销售人员,round(销售额/10000,2)销售额,round(目标额/10000,2) 目标额,二级部门 from c left join 
(select round(目标额,2)目标额,业务员 ,日期 from profit.人工导入bi线下业务员目标) cc
on c.销售人员 = cc.业务员 and c.下单时间7 = cc.日期
where cc.业务员 is not null 

union all 
-- 分销业务员目标
select 下单时间7,aa.销售人员,round(aa.销售额/10000,2) 销售额,round(目标额/10000,2) 目标额,二级部门 from aa 
left join 
(select * from profit.人工导入bi分销业务员目标) aaa
on aa.销售人员 =aaa.销售人员 and  aa.下单时间7 = aaa.日期
where aaa.销售人员 is not null 

)k
group by 二级部门]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="ds2" class="com.fr.data.impl.DBTableData">
<Parameters>
<Parameter>
<Attributes name="area"/>
<O>
<![CDATA[]]></O>
</Parameter>
</Parameters>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[with a as (
-- 基础数据过滤
select 
实付金额 ,销售人员,left(下单时间,7) 下单时间7,渠道,二级部门
from  profit.dw_吉客云销售明细单_下单 d吉下 
where 一级部门  regexp '深圳线下' 
and  left(下单时间,7) =  date_format((CURDATE() - INTERVAL 1 DAY),'%Y-%m') 
and 渠道 not regexp '样品|dg'  
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分'
)
-- 清洗分销销售人员名称
,aa as (
select round(sum(实付金额) ,2) 销售额 ,二级部门,
case 
	when 销售人员 regexp '钟意珍|陈玉' then '钟意珍_陈玉' else 销售人员
end
销售人员,下单时间7 from a 
group by 下单时间7,二级部门,case 
	when 销售人员 regexp '钟意珍|陈玉' then '钟意珍_陈玉' else 销售人员
end
)

-- 按渠道匹配业务员
,b as (
select 实付金额,
case when bb.业务员 is not null then  bb.业务员 else  a.销售人员 end  
销售人员,下单时间7,渠道,二级部门 from a  left join
(select * from profit.人工导入bi线下业务员渠道关系 group by 销售渠道) bb
on substring_index(a.渠道,'-sz',1) = bb.销售渠道
where bb.业务员 is not null 
)
-- 线下业务员 聚合
,c as (
select round(sum(实付金额),2) 销售额 ,销售人员,下单时间7,二级部门 from b
group by b.销售人员,b.下单时间7,二级部门)


select sum(销售额) 销售额,sum(目标额)目标额, 二级部门,下单时间7,销售人员 from  (
-- 线下业务员目标
select 下单时间7,销售人员,round(销售额/10000,2)销售额,round(目标额/10000,2) 目标额,二级部门 from c left join 
(select round(目标额,2)目标额,业务员 ,日期 from profit.人工导入bi线下业务员目标) cc
on c.销售人员 = cc.业务员 and c.下单时间7 = cc.日期
where cc.业务员 is not null 

union all 
-- 分销业务员目标
select 下单时间7,aa.销售人员,round(aa.销售额/10000,2) 销售额,round(目标额/10000,2) 目标额,二级部门 from aa 
left join 
(select * from profit.人工导入bi分销业务员目标) aaa
on aa.销售人员 =aaa.销售人员 and  aa.下单时间7 = aaa.日期
where aaa.销售人员 is not null 

)k
where 二级部门 = '${area}' 
group by 销售人员]]></Query>
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
<WidgetID widgetID="438c1c2c-90e2-4666-ad27-d5e684fee540"/>
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
<Attr lineStyle="0" isRoundBorder="false" roundRadius="5"/>
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
<FRFont name="微软雅黑" style="0" size="72">
<foreground>
<FineColor color="-5000269" hor="-1" ver="-1"/>
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
<PredefinedStyle themed="false"/>
<ColorList>
<OColor>
<colvalue>
<FineColor color="-13204802" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-5007538" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-13055107" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-2249165" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-8107085" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-7092907" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-10525036" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-2148223" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-13725034" hor="-1" ver="-1"/>
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
<FineColor color="-5000269" hor="-1" ver="-1"/>
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
<Attr rotation="-90" alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-10243346" hor="0" ver="0"/>
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
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-11950436" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=50" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="true" displayMode="0" gridLineType="NONE"/>
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
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=50"/>
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
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-8988015" hor="1" ver="0"/>
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
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-281518" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=30000" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴2" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="true" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="" height=""/>
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
<newAxisAttr isShowAxisLabel="true"/>
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
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=1" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴3" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="" height=""/>
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
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=2"/>
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
<VanChartCustomPlotAttr customStyle="custom"/>
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
<Attr lineStyle="1" isRoundBorder="false" roundRadius="5"/>
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
<Attr showLine="false" isHorizontal="true" autoAdjust="true" position="6" align="9" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="微软雅黑" style="0" size="72">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="微软雅黑" style="0" size="72">
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
<Attr isCommon="false" isCustom="false" isRichText="false" richTextAlign="center" showAllSeries="false"/>
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
<HtmlLabel customText="function(){ return this.value + &quot;万&quot;}" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
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
<FineColor color="-5000269" hor="-1" ver="-1"/>
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
<Attr rotation="-90" alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-10243346" hor="0" ver="0"/>
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
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-11950436" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=50" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="true" displayMode="0" gridLineType="NONE"/>
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
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=50"/>
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
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-8988015" hor="1" ver="0"/>
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
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-281518" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=30000" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴2" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="true" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="" height=""/>
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
<newAxisAttr isShowAxisLabel="true"/>
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
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=1" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴3" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="" height=""/>
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
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=2"/>
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
<Attr class="com.fr.plugin.chart.base.VanChartAttrLine">
<VanAttrLine>
<Attr lineType="solid" lineWidth="1.0" lineStyle="2" nullValueBreak="true"/>
</VanAttrLine>
</Attr>
<Attr class="com.fr.plugin.chart.base.VanChartAttrMarker">
<VanAttrMarker>
<Attr isCommon="true" anchorSize="22.0" markerType="AutoMarker" radius="1.5" width="30.0" height="30.0"/>
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
<FineColor color="-5000269" hor="-1" ver="-1"/>
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
<Attr rotation="-90" alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-10243346" hor="0" ver="0"/>
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
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-11950436" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=50" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="true" displayMode="0" gridLineType="NONE"/>
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
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=50"/>
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
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-8988015" hor="1" ver="0"/>
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
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-281518" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=30000" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴2" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="true" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="" height=""/>
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
<newAxisAttr isShowAxisLabel="true"/>
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
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=1" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴3" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="" height=""/>
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
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=2"/>
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
<ConditionAttr name="Y轴2">
<AttrList>
<Attr class="com.fr.plugin.chart.base.AttrSeriesStackAndAxis">
<AttrSeriesStackAndAxis>
<Attr xAxisIndex="0" yAxisIndex="1" stacked="false" percentStacked="false" stackID="Y轴2"/>
</AttrSeriesStackAndAxis>
</Attr>
</AttrList>
<Condition class="com.fr.chart.chartattr.ChartCommonCondition">
<CNUMBER>
<![CDATA[0]]></CNUMBER>
<CNAME>
<![CDATA[SERIES_INDEX]]></CNAME>
<Compare op="0">
<O>
<![CDATA[1]]></O>
</Compare>
</Condition>
</ConditionAttr>
</List>
<List index="1">
<ConditionAttr name="Y轴3">
<AttrList>
<Attr class="com.fr.plugin.chart.base.AttrSeriesStackAndAxis">
<AttrSeriesStackAndAxis>
<Attr xAxisIndex="0" yAxisIndex="0" stacked="true" percentStacked="false" stackID="Y轴3"/>
</AttrSeriesStackAndAxis>
</Attr>
</AttrList>
<Condition class="com.fr.chart.chartattr.ChartCommonCondition">
<CNUMBER>
<![CDATA[0]]></CNUMBER>
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
<MoreNameCDDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<TableData class="com.fr.data.impl.NameTableData">
<Name>
<![CDATA[同比分析]]></Name>
</TableData>
<CategoryName value="月份"/>
<ChartSummaryColumn name="利润率" function="com.fr.data.util.function.SumFunction" customName="利润率"/>
</MoreNameCDDefinition>
</DefinitionMap>
</DefinitionMapList>
</CustomDefinition>
</ChartDefinition>
</Chart>
<UUID uuid="c2e81cd4-8aa4-48fc-bfdf-6441817d8d51"/>
<tools hidden="true" sort="false" export="false" fullScreen="false"/>
<VanChartZoom>
<zoomAttr zoomVisible="false" zoomGesture="true" zoomResize="true" zoomType="xy" controlType="zoom" categoryNum="8" scaling="0.3"/>
<from>
<![CDATA[]]></from>
<to>
<![CDATA[]]></to>
</VanChartZoom>
<refreshMoreLabel>
<attr moreLabel="false" autoTooltip="false"/>
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
<BoundsAttr x="0" y="0" width="417" height="156"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="244" y="380" width="417" height="156"/>
</Widget>
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
<![CDATA[1828800,3581400,1828800,3962400,2933700,4648200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0" cs="6" s="0">
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
<C c="0" r="1" s="1">
<O>
<![CDATA[昨日销量]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="1" r="1" s="2">
<O t="DSColumn">
<Attributes dsName="日维度销售额" columnName="销量"/>
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
<![CDATA[本月销量]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="3" r="1" s="3">
<O t="DSColumn">
<Attributes dsName="月维度总销售额" columnName="销量"/>
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
<![CDATA[年销量]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="5" r="1" s="4">
<O t="DSColumn">
<Attributes dsName="年累计销售额" columnName="销量"/>
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
<![CDATA[昨日销售额]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="1" r="2" s="5">
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
<C c="2" r="2" s="1">
<O>
<![CDATA[本月销售额]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="3" r="2" s="6">
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
<C c="4" r="2" s="1">
<O>
<![CDATA[年度销售额]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="5" r="2" s="7">
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
<![CDATA[#0]]></Format>
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
<![CDATA[#,##0]]></Format>
<FRFont name="微软雅黑" style="1" size="120">
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
<FRFont name="微软雅黑" style="1" size="120">
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
<![CDATA[m<WDIP?ZWclDpj+*0)(:5WFW,-m2.Na$MN/Ue24u&>US6?:'7'U'O;Gd_Q2%HDH7`6k;fo<=
KL++AoosKFhl""Mt;f47CBPoBZ94f3J=7K#QHiZdrGuYPZ&+rRB-4im:!UK0hmkLTXfeYnn&
,X!f7#a(bQ;_-^+7j;o*M\rq:1b!j@L]AX`$EqRb]A_q>4c"DeU52<]AYbM53RAWn<E&'R5LlSC
R=C=f00rl"m23(fa"CE4?9E^;Y,rT8pX(4gNK3uo6e!]AqGC>^mVchYiX(8A7-880^TZ]AM4Em
r@H_)u54g7A1,S&U_%3,1]AF")QlfXT93(jUJuOo4nk@@*(Ukg4k$/g2C[(9+]A)_EsF_[eg1\
W$?TPWmH_i2g&\bKLTi]A4b:ecr`R[]AH=3)$$t).c'!PS284E`-8k;rQn:*d6]A^Mrd#c[gCcT
NO!'Vt#n6*<c4/bD#h\NMBt<C?-.N?<.I<EGL"8gQF5]Am`Z8CI7&D1roLsSs-&a;pj"Q;B+r
[\M8B8./0+eJPCo["$@M]AE(Ea_9J?u]AB_mRJcuN?gfsLV.]AV^e;]A3sbU5fkT((GIZ9'8&:`#
-hJmDDA<^>ElmH%_A3/1EirPF#Bhc#=C+;]AZ1Ld(c4V+juSp[7!:s/Z+ZsJ6$:O`@=q2CC!!
^f=E3n``T&lLr:Y`XaW)0%Z&/Ue]Afab?@bYdYDhY%2HV-e[+Eol4P":=,ch3^q@+Zs)&O\%G
Z3sO.bfuB9R]A]AD3-!_i:'g8F$AR:o10s=@@^+Rs8-?X_-a4!1^9?-^mgD`R?K)JaolrP1pnY
P?+H)u1?6!_\]A*?mTDSi!\dpuZn$X_n,P4Te,k-?n>V#!7TPIN0r_3SYqg[Na$totY%6pIJG
3fGf2&O:,'SC%>jWf=,EQJdIgimAs-??>FGHA\9[GTj(.#2`N%5O':c9>kEtu$JPWA/M:/0n
[sWKD!*Y(*2$AhCPQ%4[s,.*1!NA3Fsj!Po9_95*I724-!*NAn"\g%Bn[K]A1u_iVePM;3(Tj
eK9[pfIT"j.G@`n,87UXc;;(P9";eF!*^1$s)@ZVZQC>O?O&8%SA8nX/1'a[D)[A';(PP>9e
4@a@kl,8Jh4`POG%j88^!hd8)f/d'K'$DLoPg-?9-=Z-[5P]AoEe/<,$9.562F<gfOn71]A<C9
D_Nf]AN/%;-8XpL$K)"2cgq'+uh>hk3>aAkIP>XYGI(A24J/&EX<UArsF`T(U3KL[UK^b3)E<
N?_ISfX[B:.IN>Sh:V-6[M%TUeh_:jg;fC;19g)i!YT_M7LUEDANm[L!.@LlA_]AM!BlbY\0K
<ECE43ehB/FnAE/]Ad`Vkf+E]A[c)Yrk["n98Xn7d]A8iWTC^9nR&0>6l*DSEVY_oqDS"R%_J5u
cnQBs8o=tQeZ:jf0oDj_S.K933RS?ek9;BjXE'@CE;l(]AU"*QDUp<\[ZiM"m<C2Uk\_J&HM\
*p1*1-3b:CZd.!kD>ml@33FF3mJ,mY73RTb5]AcDKU#jAaa=/FGjCG+djl]AL+!K[>qC7YVg2T
m^@P3Ep=S/RCH4<KN<c"jtZicB,;8rD$h+j1]ABI@NLiVGNN?iaCiA@*Q.Vn7*AQ4?#(.phc9
`]Aeds9,P.JSR$c'b>UiLmMR;To-[<j]Ac,R[oe7-.Gbu!9K]A2@EZ^0o9qM3c\d-V7m3G9c\$l
p<+)OlM-M#DR(nS'""JdZuVSjdULnS!Sr^j_C[kULNR$ro4-k@G$-(NVEkpO&jh"FDko#7n"
puqfdFX=kqP`%cW$trt`:11+>O'S,j.pDuV59pCXhrFY+cdh\Ik3L/XlK,mDUpm`jSL3\=sb
+fAY?N>75d+6!.P?0.^D.?!PM6e?04g(1RFYWKK!p$jmGE*WiOp@!NpGKd\N:A1$l[L)Wb,1
I;r-*%Z5Y9GpH10V1>EELNV@Z,N^Tfu!.BV<b$)lnDaWpEB6'bFjk<`S>^(#!k@5klsPgbC*
+k$USW]A'Ff6pW";ddR^YkEG[kC_qL)_jDrG5c#&;&#E<Qj:51U[HufN7Np0grB$#qlis4^PW
UhR+ajqhY@K[4t]A`*$Be_`NrlX3D&_Ss^:ml)>:G\Vb/j+2e_&7[bJ1MXWm:($$VQ5^#4$-h
`KD))IsAT)K_KY,Q6B/^<cHcK0:JdTf`/DYs\LKZG<`+g*`Z6VS31_H!,NpKha0O"T4T8R-]A
[BI-D7eQChYg,7;XtH3"8Y>>X%F&9l"*p*d@LAlCU:4_MI11k<1U,2k3/8>`K<cM4d213CfB
m.^E?5BfkGV$Ufh]Af]A,RKX-$T.g>,$5:XqIOZLU^X[VKgiID!_uU88CD&O_&gZHB<S27"XQM
cDqLg4&$E.mlDmMe.S%mYeu8=+gkbDF1GP=Gmt+**!HB!t"39+7;1)k$h">?ebQ//GjlR_8j
4KgHn78Y.5,MD8;L_EPHX)W$WQV!6"YrSnD?#Wa@:i0N9FaJC'!ki.Rjj*W:KtSQ_Blk;$K>
$E@H1q`$!?k1-%=_DM/`)\&64^IEEM)q@^j_[JotJ7/cGT.+bJUWXn/=`mB&Ea6T,iCeH>np
r]Aj6S-CP(`hTY^06l7_'9H*6G[=D:FjHZVJ;>4eB'-;.SeJeGg-o`D>Ikb/l)*1pKe)HK/9C
"VQ!;\O6o;M-OD">KZQHV<)mYZ?"Tj'&F]AhFI[Q_J3_gbQLq\u)(=J23Hqj23Z#oS+PB))\n
U.T6QN7/E:$VtPf`gq+q9Tg/$HT@SXsg$qO\jZh/(0[,b13hhb/-MstsYEu4P)*>M=[i23tL
8$dn:,`E4XH%%d]A$F>8Bk'kkn`HR'Bu;gUdod1%.BJ2h9__f0C)q"gJpoA7\'1?*<^$j]A[5Z
VuN\`;%3C_)B(Ns0N!ns7kY/EYt'NX[9j9pO^c/gDW:'#W5:dS8aqHUO3mR;,I;-VmC7FG<7
T$?%4Os@1T(:O6gTMbaq(CtHQ[5A3k*cgR\0=Yhui)pjVh`.*UWd?mIlcqMfNsMJu%=Y'U)]A
k1$LHk&.f/Mb4cCh'`4Fr-e#,KU_YaZ6rrW.l4!R\ZiSt+GF!08N,d52tr#L!'O80@cA;KAr
:8c`0C-tls%HJN\JQQe`Bg&:X\P8r>eEEQLXI[oH_/Y[Jj?M]AnZoM&jO5.oJsN&=MZnQ2T\:
R`G`4uh&iGDURRO+VS;hlpkJ)DV8m.?9TJ8]A(,WB+IXJ'9H.Lq[P$_%ZSF4pR!NO,D&>QOEa
e<?fpQK&io/s@q!kjlB*Xb`"V/,@g;:=^&DqL6J-iP(5ESu[4IRl<ApXC7OcNH3*1M[8C]AZ!
i77QANOC!V$6Q`Rf)NQsPbP%"3=igYDXteQ#WWNa3b",$9O`9qk:)b\'e#H=hD+BZ.agUT=d
:>d#A`+]AbaIkD`#i,u+"UeV4X^4h]A6`<N0m9T(%*LRoUq"'6iaSl7F.8@NlROJ@hM+5fl0V:
LrXZcD@jeGWXAm4S+0&(MHMs=P<0aN$C38`D6saSKmR4X6#tE+af/*']Ama!Ak0%qo^Jk76LN
G`/7?&K\]A3Be]AlmHSk5-:qFY022T^)iZB2E)0LFE/d.fhLS<>FpI953+NB8SYAk9ha4q*2d:
(:aB#4??,V%0FN\6dD]ATe/P#&E>lBZ8Fp^>*;=Y64B<Oge0i[_VKXp23AR]Auq@(kp.IpdT*:
F&t5ZL"o5(>C-0%dRB=X4]AOcJ<u.YR"i.LD(n_rcoN8Om+6BiA>S8,Xb;,P&]AW1G7WesI.Tg
=i[=C]AfsXaM\q:("/eLq:J+(8?Zf!0^WY^+8SlU^^1q5Oe3S%eK[F24k<JfP?)="@,ZWci2p
=iH6kXmVh^MSomMS>2f@82Laonf?8n\F;L7U5EFng9+n4kQ7m0gE8"m=k2KGYnL!IDDrIseM
8e.:Sm,rh`TT-&8Z)1&_rck0FIUa/J#n-.N<(6;;&e@irX&%ZORZm+M"([,eW^=\cp1]AY[dh
MlXp4CXVrX!><.*q8@=5@^F\ki)AFLn9=:!"Ug4o(hjNdI/dOu3uT1)RbOD=+Z1Xgfq'_"Wr
=p#s/bBTa"`?R`EgsJKK?En]A:eh[)S984uB2Tqo>k`)%9XUXF#AF#qlf_p]ANE^e4Sf_@9NpD
e4RPdF5eSUGL%kM?TO&:ahVQO+SX=3NAiZg]AZ_f+i"<'H4QOPI@J]A>FaKP8E+$eVOFFQ15$k
PBq,1+CHN0@d(7Prh,8T1kE)o:/3_P685b>W?dZ4\'.MVG52H`lM5UhTO&'Z^<QQ#[i:gf0A
-bY-em/+[3p5%Y4RIF+&DTr=?ecjo!l0us3rijqA?/15<ghRr!b^aJ0&QZ(=e=JSnHSiUL#q
7'5:gVL[Ng?k*$=<tScC3u#Cr>',)0U(ET<EGl6M05\g/X:Xh9+b9\9SuM_.1)bB*LD9CJLq
IEZ!Ep\\i/l^gmnL?bX&efnifrO=]AY=d)!86G68!<4`OP3iFK?'p#!j=T/l/n]A1.i]A7C.:\[
tgCgdj`&Kgf<S5!@n:^)I.dHhg3u6cb*+iI$,8iqXs@pUBm4hF;t+Os3Lq#VJ'>"l`8>er:-
Cjr=.D&G/D?Q.=g<W&q)OGs%08Qs%XHo[YKYFtSYf&W8j%P\\#F-,>0`?.T@.-OSY!)VF,Vm
!:S7`@T>N$Po*fRA,M)CR_b0$O,/kcKHto7cu+a6r'c*Qn.9tKbOk"(deGj"!53FFEngRb'e
K3<o^,)dK^^(l./lJK52::9_9us2!J#fVlpqRZTImG%\I]A]Ab<'S/re'/TLu?g9i&Bf\U5DR%
(9:tda8YdIGJR2J!ch0G4'+>,KCt\hgH7LD?t!$=2]AeTB"nct5PJWqd1GF+CIUaM%&e=9kWI
5[qAr4/i:&4U6Bg3t6Jo$]AC?_u?cMEN'Rbi>+=8,W2FBAkl=g3[22b;W__I[$4e4,omoVN(r
V/I*T;<O=Y/]AF3=ETR9)X,&5cq!b`C"7@E/lBX\[/Cn;IAUE^2]AfUV'.Wjhgg3nR%GB=s<2O
5%8/!?^-(9=SsmUI"tip$YEfoT,.60O^unB"beqc!)=p?QA5"6%pr6qLe+lS4>H:Ikl-sl^<
%f`_Hb')X4ALXjI$MqMK9u($\k'KMHq#D0u3h5i.ls(Utsng&spAQK+I/9'i0$9!Q"TY`0!a
HG6b/VE%QHW@#FQe9*c:C5Yo\ZEYU=#"]A8;ae\9)UgM31SAR-"8d5`ML!s+fS*B#i?QAh78>
;S=:q+292$4m+E!7o3d5TjK+TBY?:^/rg)Q@:W:&kIJ^Ds>!:Xq^)0rTeh[Vn0>1UjP"!PFT
Ghr\$!chmnW[WIa4nabhD=bOUY+/Y\1'6n;gA-Xh$]AUd^"Yu\E-T55<A0\C"tqd=<ABr,BBl
;/TY[os^l+7m!LV0O*5Gb"4>i$C0e;ir-M[GpAT`MuQQZG^q>.(om)mR"sC7imu&@egTGAYO
FVhZ9YRgV&IN'pDGT<M<dQEoh?:Xg+akg3U1AHd2<C$Q,1aQN37p#4GN8CBMKRJU8uka.7?d
'UQOkYVMN?3g9CNeS[c+$*OPsm^':-2HGuOb,+[=b=N0Y/.3g[^r&5<cD.<Tr\p>Eig5YZf&
,NY%L:nAMYZORF"\]AjhkiJca.Se6-,:P<F8!UTL$'_kMC8h3^=.H('(L.]A5_j.W]AStc4X3Hb
F3[VJ]AQglu'D?:nAJV\I-jEsY;o\$%CnQNBt9Tq#pKR@\hMRniE(pd2'#,t3&X4c]A<aaWlmq
4Q_h$Y\+olL8S&kQ>a>")[p<drZO":^q%I]AptGNWX7#X]AA'[[@YuBP#I5'^*)&.6"B;0alR(
MX)1,s6D``GMUu9O`[oLQC@orGhEn(>59e=OD8LCU%)a!et#3[n\l68#b>VT*+XFb[tI1t<i
r\h]A4dkXpeF!p!^%O.?/U"=ZVI"NO2E5lg'qbA2,%6*U/O+%Zi^ju]At6Zg4o@Z'M-SBUQ";d
n#lS%8WX)iErT:YE<Im%9;qQ8^oS8BZYMerrXs:o`HP:E8)l-uKo;)Nh/+FQg#<o2gAdA^jG
p*R2)&N^ME%bT:sCB7U'30D_)H:K8*o*[,BkBJb-h'J%bBZB&dIVmatoD\p9d)_9$1meIR`_
;4FU)ttOG`cp$JX#nAPEW(6MW2u=2jcKc!7f8G%s8FFK52g><6>)"=O(XU8ehaW*kg#<7k4W
M;gYoA/>gou//3IWL+0u+=miM-OCVs.2J%*\Cl-Qs_D#.0C-oP*nJ0f]A!@qGg57V,31EfK04
Nh83Ad5DbUIff@_GoZ(9>4+_L(N$#uSSi'@EB>_mkJOd8WA.'1eE,GWD/K-C)\8^nO2bJMah
5DOSpbQ)e"$^=A@H)]A@D`%$C4qsYR@9<@J=p2p8>E7`I)tq2,I46J0'L<udL^!ANO2.QK8Q'
q5lZ2idPgo[#F2(^R<M2o]A>64IQTA^p+Y>8%#PX&X@0JBTd&S"kHBLH$@Q<39,I7>`iYTgri
FrShmJGLMLp:^GNG[>(0tgO5m]ATdNca<o1k#S_fS;`BhEOFo/Ef7V90N2EtWf9bl;iAurf*`
)sn/8LC0\"YCmK^n3YV[B=gL1b=%J"cQG`_ec<+m40U06;]AeM&d1V0n3iRRo[JBQ$n.ENg$Z
/gtXeAJ`dPR>d@MOD'!$.O!TlZ<PIR`?i-@ii?Qs<\<BJll594Y;GCnq?-,MEIi"+-$#d@rc
BI(H1h)r+Y=\]AZk&L[Ar1#[]AZ^<L'uO2WTO9h_7=M^oH3bl3s"cqq1bh%.[H0mWUJB.gBGnX
r8D@C)#2f)Hm2S?CmM[[>CmjPD[9d`+.q^@3PSenh1FfJY\AQ3e25dMFpHk*IEN+^7^K*-uA
%g[c:[c^0fGD#3kqP6YQe=%h&t]AXBA>uY7\9+t)G"pF4S*!.s62&GY=s=&*b4c)A-JlKK^\V
hEAo<k8PLnEf[LSjE(q/Lm-k'8(l8K77HtV0/?E6iU'lZdI.5Wq9E]ANNI=e0i`QYCp:aF2k@
JW;0(aHj.XmB,OCp\LCFVFpL7L*d1R^kt2q&pG&a1MJ!XX[.TgOA@c%hU2T'_SOjFeJln:S2
DFL?g,AimQJ;jD07G1$GRDA.f_&]Ac&LUbCT:2pZjb2E0MM3_HuqtkHpq]A9P4%DZg%3QrM8/W
kqGOV/+>dq`UF"[?n8YEHj2GBAY%_GGeQK;]Aif>-?!CjgRo%oKIW?-t1]AJ8mI$pEL\7SNheW
rJc*JT4\X@P*t@eql%*l`QDh<^[iXc<Da`5HbQ88KZiP6f&Ne(b6Yk%rVscq2\.jBq&*GY*I
0)B(.-g^?r]AVR7>d1MRf:u:2@'%!J:</7FtWr>F0_Yr%#P(GDBY@?[c5[n"he?5m@&`V6O2g
JPU#`Jf@4Lkdg68`e?g/X1-O\mdKi&DBZJ2epSHm6b<4=6]Am)WSc)d/IJ3mfjZuMA*IR_\s/
FuBKIQ6!05lRaK(.Q,iR'AAh;6UcJp.#$YLNX[O>>s0Rdbl%F'#\[.O5G^OZR:Ra`Bgg`d]Ag
&O0+=So;6MT3Zd^Zj<6WuSVl&]Am%i``3aV,j?BF@?+/QCmE`-#jVPVeO[!g=\%2+ZBS_C[;Z
HgJ^@[#clPC2H2<d"o.ZqY=bN73p]A>lkat_(Lk;':Z=5d!2Rq4*&LAL@.'3p&:EnC4]ATmYga
BPQJs((II<fuZ:Or)]A=Pi4kJP0el+K5m[oY.r-GI]AEBkf3-iRG6_3$cj!gimlMcdh?2M#-n;
I&2Wr!#ch]A;R48sU0mUfcmfpuaUJ_Ee\nP(ML4L:9#%TVC/]A+G>>V`,!s<?8XQdt6(7GH(iR
fS3(/#%/iBr#(SPF_&:nLBP$F%LQq'hN[V=G]AIj%Y`pdV*XU4VIB:\Mu/jDQ5TDR6R<<!11g
dK*ld"rBR!VM[2)#4/Ftgp",nk36cfV&\Y[LIpK\REKG(P\6/OrXr:`M#_[r[Z5Zq$2_/aDg
`)$j/d$*EXVhe:IMhO!8<M"pR"l]ARgalkW^6B;qog`N6<a)e8)(d&8j2>]A:giL0+;9W#DKZA
sW,f+2,SV-e&0XOLhK8_1hesCU^H`rLRB'c\4*PT/W:d?`@4P]AUTZ$j]Ac7gp_N8VrEDU74t.
i*ts5;]Au"1&G3kj;fs1K:c;XjT"JZZ*"Ed;$Q\@`<IS$NH'PPBlH_M>&rVh,8[($9D&<.LL?
PNqJPY4G32u9nV\gBmQtSRkUU!TPq$pZO]A-.S#)YbM=<bDVbIf6CX%tW?Bb$fedi6GSCD.C=
N:7\lMSf"W.Dj]A_bZ;%Nt;X?_6;^>W):@kL\=-m-D8`d&,\^e4V"uRSO%VG8fU[,B]Am6X"ai
0loV?[B&W,$m%W4Fm1_3]APWF9KaE`+R'<`#9)S[]AM4CG8D/pCZg5MDduDhQe#t7>pd>"<&bc
@S0FW8'rt0qU!<$IQ]AJ)rX]Ag-L$F/#P%ALoh7g;fLt?R!'^k17Jg"",Odp=.&hg-0BKhXJG:
937VtB%CCQENOd@cU0gs(Hk['YaTosG"tM+"X0"%"Xf)S#<[8a`mn%nRkuhF5f9$uX.>XaT-
hc/P9rL`b3;!A50Eehngt(c^%dOHSG)j%'&#uNE60Ec>qS9&DH?:^U&IGOMjeWM<=J_H^+eP
sU2Ci\;_QM%X_1pE)DM1_EW8#54%\MVjLMP"^+9!fjO@B?.25'm$s1Ve>nk[#]Aq'=!l6f#W7
m[2:nm'92T.Jp^%Uk[(DLcbNb_;5324<JW+)PKj1^_8hg`R]Ak-op>n4Z2b5oj=3@IL[B+/8g
8,**;f]AZVqc-PHAQ2VO[U/Ff*kk]Ao%e$GnMa+!)>,V<P,MinK`m#0kj>\l=f5d\`PqC>mKFi
_r?%Ao>cmB"-@D7Fs0#$Fmfh7C*sqA,N9pf[(jh`N&6q!Sj3E!qH_ap-8]AFR8Y'KW3*%(8<6
gR`<c#/Bi8_A3TtZ4#TY5<cUo:#3LgCqUUt$".W]AQZl(8,.eCBs+Y]A,s.:0o`(^*SYd/0f/C
95,HpIbZnr.B87&`&Za1[HA_X_6m(+#6%6BkBc6PJ&+qF2.2c6bH^El"Oh01ml)4#H3uVTro
VAoRL`6OU\jpK/gXU1<66D<DYSPC+i)/:*pnZfoUmb_=4l2<A\rWb50Bq[cT/FV!_b*"+q#"
I;e1-?;0lqt``AuCAe]AgFq]A5'dPmDI46(.6>:Z<J:Em)N[/$;l@/eq.GZlaIoLb%Y0`aM0la
=PI.E;,1UWG=NXY$7n(Y"NSF9U#.isKl]AOrpJ:n`9\j7Be9KK.'u6%p>I9&rV(R"dWVoDEB'
[6i/aJ58?u^M/#1mkNr;.Qp:"oV8:-%q0+d3eHBfuXYUB4al;YO7QS/h-pNVGA3<X#dqruH0
HP^kilRSo+[]AmZ#A^?h^qo)L8n/G<oh^Lh%/*+^bIC%9:p8GOeA^m3CM)hY(IIEU4pIuq4";
4:ZHn!oQ=Xu#n'f@-oEomt2u\-2Tf]AZRLR7!S.iNK1<cnC7']A'kW'rm]AF9#[,Wla+ZoU,B$a
HP+O.*Jj/<r7mh'oW4O(2s-!-WT!aLU`cn0+KBGu+l-aE$n^?QS3rloEqGind(dblbI]Aj]A*k
Ji'-n5PcbWl/chH+,7D&'#-J*%kLK#RNR#P+$Y=[\#%7VcFcXC+4N#5]ABYK23#.SJNOjV6ou
r^gqG9&h/uBLi+K&&D^P1_Y?FsU(k&^-(K!VATM*lii([nEQP4Z,44BC9KHAjq:Omd-#&*KD
%!XHJ;LB_S9(9p;.X9!M8fqM]AnqLG^)YdL)i?RPnt7cZtt<U;0_nu>X2@.K)Wh/-`OdI56,l
WHC+j.m\)#R]A@"/A&P+EX#qeC*C"cIcGm8Q\+07BNF;_2H*!Y'=.eY#/*GGgp*Uig$[fP?9h
!^?U[c..R6i8,.%4D]A7oL9M6F?=NoS.F8ajB=.@"e>]A2SCKYE/!T;I8fsM-]AI[P4)-^PXO`#
]AFqA-H]Aeo:%0qr-E35?8m!R\J(K9D6Rpg#>81qdE[^YCG8Dj,>^]A%1qN5TZ+??es*OF0(M4r
_D)G#rims7@\eB6BW*-+^9jI;1P4ZdiV29`$rF92eYCI_Pp5"#4WY`[ANAek`icN\"Cj#u?(
.%X/eIrEFMXm*+ZLIfRD>@';Bo[8eq>L8J=a2(^!8!UVs-)LbM"NFFILp?&`s8<a;>Et)ZX(
KfNG:EBkqk)NV-kD\uH=O7q6MI%a$K,n7u$;UP*c]A(abkf9Y0#hbL4cp<F5B]A&]A.<Rk=F(#F
B9:Y[Z?eWn0l0s]Aq:E!<pSI3-QP)to>b)]A[/SXecadbTPm%Hb>rPh%$Xup#u&DD07'r%KOoo
e&C&ISf&P;3dWMA70@!6Y*g1=U6.loI$l"O5H>`PrnC#6+\N75hrX1t\V2kFRD*)tp]AFn[3+
fkV-19]A_UT')f<e'lHJZ?f5]ArJ.UoR<T.B4L-pW&r_>jY;Q/d0h1LF"Z<o.HtG`a1?o_I8J=
l!+!<m9k#_Be(hE&En[r1(K\3&jjn('f.g.f,>:Z/k\uDa@\<eHNh,uZfGA"nY+pCce`]AP"n
]A.D!@gD9.qFk]A-o:>\J7>03le/4K"?%C]A;d([:QNlHp6r#ALa]AUuKYV7H0nQgWG2a\5M*d,]A
]AK==Qeed2,_Gk;h%p8!>Ri:cNA[!Ffr8O,'9f/c%LPT-NJcC#b/CcRY9K;_lR2"i7qF@B>6q
*Y<c;U8IW[2ggG+%<'CPX<e(&5'`(.!5rD+^M@W171O'G)pUde7+fBQNS+V5dE8UrRfc/HaB
\R)IE(N<VUc9k@p"4O83%3J3_&#7W\2ABoH#T.T@ZdKCC:)$3AeipOS)AL+&J*HNB"-ioPl`
@hs*e=s,#Mh)iLK$S*i9q%GMg*K5KKn9uNR*H41pJk8g%<M)b15(&b5<(rNf@9B9KhP.UOm9
l&Xu98NQ[8j;X%\p]A26?I)k9H9Okh"^tDNYE@?p4ZZ[\!_\&^`Oo;9)!m.`flTAlN#SCl>BP
Sh4t:]ApS'K+O\Y]A'4$HpmWTRt4q#G-O+4/VWsg0J*YcS8Bt0,-7HJF=RF$<LfV0&Bo@Ir0QV
Z##hZHd#?Q$WYJ!O1u&+S5/KJD2S/]AJmBA8@*EB/1P=F/#nhb$(6BR"CB`0]A<C(<s,>]Ao/_j
?4VaJhT$o*Y$;2;#G[?nsD*Dfp66od.:tmKVdKLf@il_Zb>KX^'-5duP1#k:%T2?J:"Q*&r\
CMBsu9j\tj?,$n5!+uZ2cBs)NkJf$\u1dV5%p=FbR$J@%D49-,5MIV-2/!/V"O/fOB_lLV*$
/.EcR)*j/Pb566RN)?"_[sgJa/7QK<bm?K)SOS57S<gXp9V@ZB1I2r>Eb$hI`4eNhcMG$L8M
Oqm<!3?'0To)%[XB19u1kh@L=D?,0pQ%rPaY[!He#j&7]AA4PP[P;lUEmtj"YSEA%8YM5ub9P
2.Lo%+^([Cf/iQb_8/^T6NQKP_Y0Jm.Hi/3KiB$ha/l6&Q):1(SD%[H(,sVXDh0*:RM,PNg0
OK?!W\\V&FtQQleU0`#KIU!WGs0<XJu=]AOA02)27/@,c6pKT[@'cTS3DlV*YIZOWW<o!%6>"
N%[NGKnMYg7:bM1[%f((!aF[ES51@N6!BVgc&C.&JU*VS.ILE#d(jqhMM]A@b9j6dZq)LMV,L
5RI+]Ak!oD*B6Y0$P7.1CA57<@a=>OR&6f+$;+OS5lKIHr*cS0)i==eK6*%SOh(LXMP!K_4-.
J+@U;n&4KK[Z$9FjD"nfrP(!r!#g-?.L9PQ%7R4Pfa-$b/^_eDt0>A-Z1.EJ??>aj&Abd`+i
Gl-rjN!7eO!UhQXI&fY!l`K!+VWQ+3biBWmbTWgM4lU=.meop8=\d<6ph8#UQ*\(QdYY0-(?
Q`HFCrhW:<9c^N+ed*`$<^7es_0BCkl3mf[c0U.05pNF:p<0jfZ8qpE#$;UTcfa`&/(+lBo5
OYAJS3icM^Z)^6?#V1+[E(ON^`3H6I\&Z7M6<R:4cOC``nHln3Yqje/OQtcCQ0J9MJi%.3<G
#R#h_[X^(X"qtqiAO*uaYHTaN4jhDOPW;FgbdP1Z^Bc9R9(_@-C^!GcG)[R#)QeCDm([ecMW
sRo\sM)jm:B3#7M1"X`P=`5*lL*`)p1S"Vfl.g?"q*4`KTW(dR@*<g8CE,.>NA[;J&R\+%FG
#cur<E_8#O/KITb]A'im[nDBMgBbG_#O;`K$4,J^?r:d\EkCReB<#SlM)5d#SB+T,3X8Zl4^-
<;3_JT*%3X0E4(%2="0OQj0&%)/l-r,*:j)Q:!NUkZL#BeZ3"++U^g^N_bQl!BSM(9%0,Bf8
"@Z&XNj)%4o>rJ\6cn\sH?mT#hg_=!dFarJgF*FdmfY6H(/C)d=QR,hSmEdL(<rm3+$enDJ:
"elVOYce+@1X2/G!EQlXbQJ!lYN$/Zl'RZIJ>#1T1@0Z;?m>tko()@QjPGXRNXJrA<9!]AJ*:
2LV:<![WpadSiZRAggtN'J*Wml+-?K>n/V/)9XVnt97"ASP2.i5AVWB--U6)!E(1VO?YAJt/
H#>mrndrEc7n>LE9SSkP,A0eP[;CK@Ces1>SLs]ANV_R7qB(*-(HY9AH!9]A`X?nRO?Q%Q)->.
nf8pd.?nqg`/8Yl_VLKo[pB#/\NMArj+2QhGn\jjK3]A2'>/2p*6J=CWWTLH=0-3#G''?o.M#
mREiu2NQ:ojeV5liZ"&@3ioHe()rd"CYP'JAH]AJ[]Ah3@ou0n]AfeJ_9?SJd8$j",]AGcV9b+dc
b#\8=/<ULqEC2tgOtS'8=#R`8#?bV/+@omf90Xte04aimVB4,0?7aMj#kE,(;\Y@Gl'\TY=W
RJC<Bj)3=s!\Oe7Du%k92)1L8A[<7@M9&Z/FK:__Wqs3;)@07!&REV?Q?SlZD2;3JZTe$"'>
[4A76<Pl1#]A?q).REq$aQN(J[M$aR`WPD#]AaoZ5d:gF:!_LuqUhm]Ahm_1l6LPMsKuo*6%t9H
oM`gqF_`e3'ZXI!fEL8;<>Jnh`T's++"J1L!^VjX!<)L'%bXJckae6N6O)KGE`r>>^2$FsFl
-CXqMD0bAU*@kJ[G>"$RbGVC@ZX?\lc((rAu'(6,)Y]AfD,)o@lrj_0Jm>G;G$ff=\]A`Pc0hd
KcW0[hIQYq:<XuKD_'j0"Q:q<Q)Y*KT:NG6;IIsG@,ain@_m0ha"ZB,H'I:C58g*g<3$m0:\
u<a)qrYW]A"Q$8N2T:[Z+,4W,#lN[lQ_JWtR5X&I&@DGZn-_X'^A(DY+[&hugt?3EdL8V[Bkt
Nd`TJ#Tf><**7:CXJnUN^JQ1&]A.8d,RLg2@f(hSk^K]A%nD0Y*qGFF:`WAZ3"14U#%m%]A_JK/
8:j^B!L9',*._SAulc3)G8CQHH&'PJ<I$VW$(W)sF0CV%#6\...gh2t8fN6(@d6!(;k"m%;X
SPUY"Ln_]ALfBr">%n0(6"iurN1ptMo(m&o#f7Dr<9R\c.@c5PnZ]Anr%Dfb1VmrY;(DT\Ra"Y
;+\!JfS+I_*!:lYOC7*l'G+YFn/4EYZ;,VAa`cBJdr^:9Rb;!H.o\L-poWnTT\SWm1K)<b&2
<*<bC5XpFmKg?iRN@)"]AA'HT&R:^1KVn?iNfi!d/b;@4A<>M<_ge+8\k-MXBj,9,:q$H32QG
+s`@3k3Xq[&SBjb8VjQ?/u(5,.X_eA?Cj=t)H*Ni6dD%CoT7rT5hGb.fC[]A(q2`jL;mbBkD!
BMuMg\_&PShZuW)@KEk1AMNY>$']A=B\i")l*A'2*_)2Y7YQ@et[ed.e,/$\)P'G0.1EN)2_5
&WkQ$TS2IcHNSQ?YDmDh"9^j7kbh\\Zk'I7kBKcRS'C"n%95IPt)l@J(rdeFBRUV/2XMn7co
f*ipo%S0r1,jIVAJX^MjTBMuN(tn)0fqm+DI$t^AR;/FAA?Jn8I4*8[45n`jc90I<@H^NX.3
`LL%>YbY2G:WcLTVXlFQ^g$59ebghFS10"Ged9I]AZOhMA'F*BfCD2('?%GO=2Jr9Lp3"JA,!
N<du3!OuMmRm<D<T0dKEE#8WfX8D5)IK+6c<MUA"-5N5)+5e"4j+[M+_>Q?QQlF`]Ab-EO-Lt
=R16!;e1Bn6RQ;#qOSlSLp'i&S$b@>TcF2BV5J%N_Vpr^SQ;?;]A9,^DPGNJ1XoBCA+AW8"rU
e*dmB[h$t2obG0poh(-OfLFs1\Y_?V]ApI5KOc)YnH!PIUomVd?m:2gkn6a=t%Kf#6eq5.VQo
d:Os24Flu]Ao^UmFgIXd+s_7uEQ:dEkh5DdlNmlc*SC/n.J2QCPFZV9K%00mB,2,+Xc,BMo@"
1Xp\W63A\]Atn?gb\aJ%>T"s5j7'rKmC7pL!@'gjcm7ErRf\CYPqQ'0hh/]Ao@d'5'_Xed#G(j
f=@aQcgiahEHASg\_8^s0B4_G0B4_G0B4_G0B4_Gs"hZ#e-PfPfX<cTc>Qe/Cp$`E]A(P9:!!
~
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
<BoundsAttr x="0" y="0" width="423" height="101"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="241" y="52" width="423" height="101"/>
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
<![CDATA[月维度渠道冰淇淋毛利率]]></Name>
</TableData>
<CategoryName value="区域"/>
</OneValueCDDefinition>
</ChartDefinition>
</Chart>
<UUID uuid="5c24b686-585a-4473-8121-259d6d28251e"/>
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
<BoundsAttr x="0" y="0" width="257" height="118"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="695" y="178" width="257" height="118"/>
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
<![CDATA[月维度渠道冰粽毛利率]]></Name>
</TableData>
<CategoryName value="区域"/>
</OneValueCDDefinition>
</ChartDefinition>
</Chart>
<UUID uuid="6daf3d95-01f9-4d4d-819e-29d104169021"/>
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
<BoundsAttr x="0" y="0" width="257" height="118"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="695" y="67" width="257" height="118"/>
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
<![CDATA[=FORMAT(DATEDELTA(TODAY(),-1),"M月d日") + "线下销量榜"]]></Attributes>
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
<BoundsAttr x="245" y="153" width="267" height="20"/>
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
<![CDATA[年度线下销售分析]]></O>
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
<![CDATA[m?q0XRTC9F8Sfc7*QndmR\`KU[RQ`U;K#LoNTmAr)DO)e*@s\.TOY$&`#(cP88Lt/'l6ennI
k6-'IR[t(39LU^fgmZDe#a9Jq9_jQH2Jq77:MpgGSRVcgrpLds'*jlaP3sqs=?3q5QYM8T8i
nG63=\cA<q/c@A0`qLLmABo]As5SPU>q4[C3om)6F.s+G;f50N06roF$/[8]AH;]A15'*<]A>FE!
53^=nDA-8<jE?)T0qHTqV$^)j6i*iP`lCkp4IsjHhPXig%nd`n<\j:#9:cr<O6%]A:N[UJ*]An
Zl]ACOGp64>LmNHUq@c;=@rbI!-^ag\^NUb0&D>UiF"R<?I05'6t5cn,pA,`B'a"+'sN[uf`s
\GfCFbg*YnoWC<8O)q`]A#<qZRb!Q,pA),=.Xc)D6%WGe'6.9U"3qAA*^L<@uMj^mSM41'*g/
bmuNmb-PY2Z&c_>n)4@RG.DXt8+m0X0M%-b#8CUYLmja_5r-3Jp2Vg*DPi"7.EgId<F(gsOA
e6Kr:LhU4h\.`CK/Z:KE4XrO1DjHn1k]Ase6O7K(sfL/T+O1L)'FJ,C`H`,%\<%@`[j:\<Hep
q@),Q%HcRUJ[n")+Z6.^LsG)G^#>SB%H0!q6-B2fL]AN/UTZkrM.s@3.U<cldHO`^GL2#t;)"
`#^B/;:6pU3G0TV)d_e2e=o;(`TRWVn2[X:Oh[^M$5$i2G)7EskYgr9QAQpQVa#b5<l`E69I
)Zd_0XUZVafZhXA/Za3F5TFndmZ.,m5*2IT2A@9^QRnKVacA"1XQq2Z4lj$#Q$h&uobG_g0@
.B`jp?Wg>ko.bj`KMc7F_kOq^1^dECcpPpsDbhk`k5hla,Yj;RQN%iV%Js\Xfn:Esn$FGZs9
qAHPs*jtTO[QXJ[1($('$#=GkIkccn\g+!/Qd/#oC4cOlSY1"l=1RbknVYJ*#VjX*m[`^ONd
j7617@gnO%PUpmn]AFC/bd)`7VkuMV_Dgg\B#ULjZLJ+9M)O&2]Asr2XnW_FCc28eT-4(h&K6S
W2!99Hjo#BLpG5QJF_qpXtP#792Q4=L]AH:m5B*ZBXTj#NZqd8.`b4+1ZLL7[-ea;Fa]AZ@6!p
gL\MBjLK3ei,+TgRD'8)NF]A3NPSkh]A,o'LB'd$)Sbj0>t@=*,%]A&`b^qsCXo&?_`Kn9_>`ah
"GF5Z68o'k3.-N>eCfI[a'gg5r2IE$Jp'VF8OM,g3Kl`h5Z/Ef@C5V7mK-!o[RrXsh)-Pik>
H^@pAp&[O(A/4<J93!4(DealW1YLo*OH%28SS%@UohiGdoIC(;u'TBbr+$DVr5!)0%W^ZU[E
1D\6+5\ghK?'c^=[>HVSg'=EGL)&.N(S/<0TN8AA<`W#k58^&E`a5S>j,@Gr"=:tOX)RD:ga
pcE2d;a9005%O#fE@69*_TZ8ESSX!j(3\ZhH4(B"HT4c#)IMYM@FB]A]AQ969(gIFcR#;D0qQ;
1Y:KBo_mk;nqhknm0ZR>#-D1obHS#\N"=s7M@K4d\f(-$hTQ=&Q@u,nH43r\16,@"YERn7V8
4-lVsEhWkqc:LH964():M2%QE(U:Yp;qIKmn-^TWMo"[;aa&#tA8UP%^Sn>OG2[g&&!ehD=n
tS<?+sXd-8k84c-9i;!Ug;pWKo)N)==WMaF"#FCa;YT#JZ)]A0ZGO\<Enn8Q4;fPR.d&?Ga[_
]A@$7C9GNJR#:>6b23!&@hRbKR#t?P)qLVWo:Y/1k6U6!ik[-36h2rKhqM&r0hK"WP;P0X4;s
2;M<G20p_`m!!0rjt)_YaQrfE3fM+V]A17r`(Z"pF8W+9os*Yr.G&,NBSW@jiO_]AO58,j]ARf^
"8".:=!<sT3,sN7Z`C-sF/f586r=`aAZA)/r/RaCV@R7c0l;,*Ug@8j3fG_sX(HQk?K^/k=R
Ga7hmY<XR-GWc0?'A,;@/JS,@BN&7QlQ1Jr=GbWCB64Mei1h&-FsnS&[.-1!!P_l77kHBI0V
5R$.$*Gd4he2h@5,%@$0bjWCs"im\HI%*uS;eSkrH"KsR@@hQQPik"&(E(md1CJocq?!J:``
,7!dC*moZ![^@F4B]A/>$ic`J2NT4JR,_)N5mm3-lDLif:Rn^Y2-NH_F9tbW#L%$HH%NWk/$2
%N[^-$<aLb'U>]A667TR1\P8asaf$\R<m/agaGRld6,,hZ/u3jY='(D$QM:]ALYq!!Q1!"]A,1&
:]ALYq!!Q1!"]A,1&:]AL[Grs?8/<mCKnG@+RdM')O/g$nT^]ACoI@<;IKE01;Q5#/CK]As3HWV1c
XY0FeR1]A#<+A$-*HQpk:?Q9~
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
<BoundsAttr x="245" y="356" width="267" height="20"/>
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
<border style="0" borderRadius="5" type="0" borderStyle="0"/>
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
<LayoutAttr selectedIndex="1"/>
<ChangeAttr enable="true" changeType="carousel" timeInterval="15" showArrow="false">
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="96">
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
<FineColor color="-526345" hor="5" ver="1"/>
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
<![CDATA[单位：元]]></O>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-5000269" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="4"/>
</Title>
<Attr4VanChart useHtml="false" floating="true" x="85.0" y="10.0" limitSize="false" maxHeight="15.0"/>
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
<![CDATA[线下销售额排行榜]]></O>
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
<Attr class="com.fr.plugin.chart.base.AttrTooltip">
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
<Attr class="com.fr.chart.base.AttrBorder">
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="5"/>
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
<HtmlLabel customText="function(){ return this.value;}" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
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
<FRFont name="微软雅黑" style="0" size="72">
<foreground>
<FineColor color="-5000269" hor="-1" ver="-1"/>
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
<PredefinedStyle themed="false"/>
<ColorList>
<OColor>
<colvalue>
<FineColor color="-13204802" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-12212362" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-2249165" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-8107085" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-7092907" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-10525036" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-2148223" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-13725034" hor="-1" ver="-1"/>
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
<FineColor color="-5000269" hor="-1" ver="-1"/>
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
<Attr xAxisIndex="0" yAxisIndex="1" stacked="true" percentStacked="false" stackID="堆积和坐标轴1"/>
</AttrSeriesStackAndAxis>
</Attr>
</AttrList>
<Condition class="com.fr.data.condition.ListCondition">
<JoinCondition join="0">
<Condition class="com.fr.data.condition.CommonCondition">
<CNUMBER>
<![CDATA[0]]></CNUMBER>
<CNAME>
<![CDATA[SERIES_INDEX]]></CNAME>
<Compare op="0">
<O t="I">
<![CDATA[2]]></O>
</Compare>
</Condition>
</JoinCondition>
<JoinCondition join="1">
<Condition class="com.fr.data.condition.CommonCondition">
<CNUMBER>
<![CDATA[0]]></CNUMBER>
<CNAME>
<![CDATA[SERIES_INDEX]]></CNAME>
<Compare op="0">
<O t="I">
<![CDATA[3]]></O>
</Compare>
</Condition>
</JoinCondition>
</Condition>
</ConditionAttr>
</List>
</ConditionAttrList>
</ConditionCollection>
</stackAndAxisCondition>
<VanChartColumnPlotAttr seriesOverlapPercent="20.0" categoryIntervalPercent="20.0" fixedWidth="true" columnWidth="6" filledWithImage="false" isBar="false"/>
</Plot>
<ChartDefinition>
<OneValueCDDefinition seriesName="类型1" valueName="金额" function="com.fr.data.util.function.SumFunction">
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<TableData class="com.fr.data.impl.NameTableData">
<Name>
<![CDATA[日维度销售贡献榜]]></Name>
</TableData>
<CategoryName value="区域1"/>
</OneValueCDDefinition>
</ChartDefinition>
</Chart>
<UUID uuid="515b267e-0607-4eec-abcf-3ddb8f19588f"/>
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
<Chart name="销量" chartClass="com.fr.plugin.chart.vanchart.VanChart">
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
<![CDATA[线下销量榜]]></O>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="104">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
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
<![CDATA[线下销量排行榜]]></O>
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
<Attr lineStyle="1" isRoundBorder="false" roundRadius="5"/>
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
<Attr lineStyle="0" isRoundBorder="false" roundRadius="5"/>
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
<FRFont name="微软雅黑" style="0" size="72">
<foreground>
<FineColor color="-5000269" hor="-1" ver="-1"/>
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
<PredefinedStyle themed="false"/>
<ColorList>
<OColor>
<colvalue>
<FineColor color="-13204802" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-12212362" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-5007538" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-13055107" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-2249165" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-8107085" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-7092907" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-10525036" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-2148223" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-13725034" hor="-1" ver="-1"/>
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
<FineColor color="-5000269" hor="-1" ver="-1"/>
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
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=20"/>
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
<Attr xAxisIndex="0" yAxisIndex="1" stacked="true" percentStacked="false" stackID="堆积和坐标轴1"/>
</AttrSeriesStackAndAxis>
</Attr>
</AttrList>
<Condition class="com.fr.data.condition.ListCondition">
<JoinCondition join="0">
<Condition class="com.fr.data.condition.CommonCondition">
<CNUMBER>
<![CDATA[0]]></CNUMBER>
<CNAME>
<![CDATA[SERIES_INDEX]]></CNAME>
<Compare op="0">
<O t="I">
<![CDATA[2]]></O>
</Compare>
</Condition>
</JoinCondition>
<JoinCondition join="1">
<Condition class="com.fr.data.condition.CommonCondition">
<CNUMBER>
<![CDATA[0]]></CNUMBER>
<CNAME>
<![CDATA[SERIES_INDEX]]></CNAME>
<Compare op="0">
<O t="I">
<![CDATA[3]]></O>
</Compare>
</Condition>
</JoinCondition>
</Condition>
</ConditionAttr>
</List>
</ConditionAttrList>
</ConditionCollection>
</stackAndAxisCondition>
<VanChartColumnPlotAttr seriesOverlapPercent="20.0" categoryIntervalPercent="20.0" fixedWidth="true" columnWidth="6" filledWithImage="false" isBar="false"/>
</Plot>
<ChartDefinition>
<OneValueCDDefinition seriesName="类型1" valueName="销量" function="com.fr.data.util.function.SumFunction">
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<TableData class="com.fr.data.impl.NameTableData">
<Name>
<![CDATA[日维度销量贡献榜]]></Name>
</TableData>
<CategoryName value="区域1"/>
</OneValueCDDefinition>
</ChartDefinition>
</Chart>
<UUID uuid="7c6c4848-2584-4100-a95e-e3d8aeb753f8"/>
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
<BoundsAttr x="0" y="0" width="417" height="184"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="243" y="172" width="417" height="184"/>
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
<![CDATA[m?qZfdoR=#BsghTgd"\=d[!0r=gTSS&5k#N70QPN4X`i4+U$.'@SEMh6:G<N>#5b[X+CI/+A
5$tCI!OuX9iLhYQP4C,%Q7@6_J)G3G1P"Q^MpWS:(25J+(,5^AHd#n"09&52kaDY[[224Ztr
\,<r`0eC4<;8l'A^ce$A&9@B0fRd93@&rsIB31ZEqc9ZTC%mSYaG<8o_o4Tf1E'7o*;KqWuj
1oSG8o)a8Q*)ccSWr/Z_sQDdW+K\>A$qrfE>I,XYf4L6oipY!/<Ea"0)F0[*[UbdSh>pNAtM
S`3sU*iq.;D>2$F<ClhorIK%mG_J8#Vi]Acbf0%bZG^p.@'9_$n/3f'Rb%oN&#Yc7AQ;+<g40
Y)kXVB[.>K]Ak"ifk.:6"M#W"OlrEYc9tDTF]Au0YYKWWEU!n,A'k2gp,8cPlREkBUVJo\iSS7
`T;%Uk.Rm7NuK@_PI[b/2!-;2*`-9jS(D7SaN7]AS/3YejgW3N3LdfX_hF+9NB=Qf86OXE$;q
slOuKXh&GeY//O'_Pdq4m?q)9R6n^C%VOtRPSTm"cSBfIDTO]A/e$]Atl50W32MFrlja!XF:aA
^D"&8DEHdK6KHN%MO@BfIMGeNE91fE`>^*-nD?cE/%5G/NB,"=C3S.pBEK%%C*`+os=U.ebj
BlITf>^9.6<DX<a8WjDf.aQ1afjmWZpNUsO[Ne27U\[.L"T+Ghk$>gWl^=m4?ffH=B-`P,*D
mB*`G30?q)Lq`LF+0D/R2O=r@T^5derS4]A\WmWCT6an3,G?#,'[:\`,3Nq<K)Z'r+`GQ;N<D
fXLX^BKof)6T]Ac24YP^$tD<o\-Ut3qlQ+h9U/7pFG$a>HiYRL-LJl1G?.pZJ#>Je8,!u)]ABX
ab(l)2RDJ`VCdY874rUf$?nYX`LcuK1Lt+>13SstHq@<tK08%dU)eM7m4<<]A[#6egWNqHo9]A
O,W-&D3/TOm/Jb$MO/Dm,4JVo4O_9Rt=Jm4T5*<SUl8AhiRMI+hnU%)_is&&k_OT#e*2\k?2
!Y3#M>%;Io<HY\U2363c(8,dap+ba.j)r&YZF7U0^T36%/mYA)Bp6=O$;g*tb8:>a$.8)!%t
[]AWHoB"CH8^K?]AO$<poi*+Y?QS3dR$/?Wo)4ARm]A"Q?lk4C';Ze_9#l2.ngO2)fUZSpP_&UZ
8RuLZ>OnIg?6R0*di-gri5+]AEMN7T,1ZiCd&F)9B"e5o'o4;\RUU0]AV\Fr>b!'Qjfioc,K\p
4D2qg5qBWr4CJ<<H\T[EPYQ06L7u3nCa=4SsDF;MhG>^3t[L'WDmMQ5L7lf.g?t(*R78*1IJ
;Fh%nFrB1TD<8PpUoNTLAD&m__2QHH`V4kI#u\06[f3L,0e`<c586-'[U`-m2bpHT;pCo]A4J
5Lo$.@A?*1smMYNMJZI%_+7+^S$rdH+Lm,(Kl=U)c%-O*)b')>etB1,qEQqbD'^&u'0<Z`n!
6P\O4i8.Juq<ZS`1`HfA9R/>$$)'@Jl#K!a8u.T8GYtZ_B8:W.j_]AB%\Lp1$]ASK!+c\]A2nU#
>?=?V[^(n7kC)O\0PIYDHHm7!L'[X<85CWSgb08lU@sd6-`i)mSjIJ4H"n=:J\T@!MLS9LJO
uE6K(<Uti0"g:t^![`h#S[F:)uRY^2c\6sm#/:1'M2bgT6=lpdHh)R8!NE)K=Wu9u%6PAD:i
[!,)#3:lum;ppofuPIgVuR"a&X7QlAT<.$Q7mT0J;CoRG?"JGZIYn''`eQGStOpSX7cuGm-@
79:%GcaF*C]AG$"2dR&EU?q%K>1YE#Y"tet/0;hE0d&X"Uj7/$NlT<V2gelLa!golJX#f3S,P
[SO]ARUBte+j$t(qp;q&_.2dj:n[D\t.TZ!"UiON=O8Ac[.r`&*9C;US<H7!hN\c(KZ%OnYXd
On1QFuNUGMJ4(.^->gc^86=+%$Z6W"\ej;Sd5la6?Oc-V+B'?))]A<M)-D0.;Ei:F@!C\g[.C
EI(WkcZGO@jc'<G6Eq,eib/9R"`5eA<4?9o"=T%eEr&dO:nMZgB@"]Ap.grA&GmD(ne+.J"F;
<#)5o1hcEYDZrb>\(O;V&^8UKZCoFIs!LgO3_GLD6*r@/#dC)10'!p'a@.$Vj4[e9\qIpP,7
:Yj%er@0cPJed&0!$A%;[p`/a/&OYGis2j^/@MHB5kZjXHpq-<>"T^UZe3(sI56)UEnK=QGR
rc2%)(F:m95aLtu\Z!#@]A@,=)6lbcH;;^U.4g*nUKEddTo(h4:C6e3.Q[1E@:+XY$Z'X&fW2
=B0Sd"DsM,Y`e_6lBhr=b?=eZH@?$'#RD!GtGh)7ST#0dp+eZ7dP6a&/I!d?GWo2($"c140o
U<.`haMX[ucOp8k^pJL3LUg6o#]Ar!eRW3"qj#nhB+kXc<$GJ+`lVit[0bK?6r+@@5:[r?pg7
CbjkRMkc<$hp`NiniQ1I=`Ibs6^d0/a*Z!;,b,A"`_BV;ZgZ*]AYC'u8B0NVj+/5N?%NeY4pi
V3dM+/m3YC,9X&=*TbJosM\(<hlIa2AHNH&STXKSXa#HOcS<?7EFaM6$FY%1N"Y?'i@rm&B/
j,q[X7uVSV/Cc4I8a-9\>\otUSe(9`b_rCe3Ofhsk2@G<C&bF0XJ!aiaG"SQei$okpPZX2Rf
b7S@!=i"\ssK-:d/Kr5^CI6U5c"V<FaPVnstBcK?%<`LoQ%Y.mngmqi+-S5IO?C]AAg&!FX0O
5\'&&k^mfpXH,ksRCuR+5gbcE8H&13(+&=M'mTbGRAs+jT2^mPaa:[49jk>@]Ad@PJ]A"di15E
Kce_hMPCh[PCc]A?/.t[dqXI/TTJ(aW<L"L-q\mCl.F.?Jaq&rguM4`Hr!I..q6B+riIS<`)S
Zn5.:@picTh>CL#5T-`<Ch%V8'JcNe$FLT_06>i)>Y/23KR`FF@Q+Tme.fD;1I.=OqKq1:^,
J?=jRQH$"AdS`8u0?^28APg*<UW__lS5P]AC%<l;/;JOA\+N2]Ah3E,DX3Dl:5Umqb$ZR2Qe%g
T_#91ccp3#E"p]Ab2MAif?qUUXH/#LaJ\sMAN^81j6IGo:blB\5rK*<h;[G[$A'IRG\+H?m(^
hE?@4^\*cgG-1!j%(CBF,>Y"U7TgeH+GO70<`bB%i-jCGKSJL?kePnTN3JEUgMnR\ER1L:J)
rM&m!ZbGsUlIX^]Ao4VA^tFHE`NI]Aa`!4.e7mlkJ%VD0h>cZdJ$$%1b3cfL":P.q7`rV6-bfF
>`(,e9W9T]A01r,EE#jGQO'rdTJXE<3/-+SmQd9ViAuQkEZ,1OW+eH5U$@)TD3'H/?@bfg,cq
>ZGj!CCGGc^>uMUSh!KfW+A'`(\4rrA+NiV_fh)JZ)/uIAH?JpC]A9<9,#a=Y_kbSR?t4_A/]A
a#PIr6n0e#%TNfj7[[O:qVt^r<I&de(TF+_or<J]A/ME[2Kod\]A6*fW%PHYf"a#\^p6Abns%Z
ikOsI)Q2YN\?&$&'UnNV14Gki`2$1XE"nk]A9iA+092Jl@'UampGI;orI/@=M7mI490rZTRpr
M5!k_("aR2q*SWE^!ebS"1lf->+E0^n3>OWF7C2aQgpd-]A.kl7YXT/%>f=TLQ0<`oYI.-H*j
RC4;u[++$'GW13dtaK-n1j/nF?/;rDGMaI"b#-lfl3jhYMqTq,`Ul-2hSTD/RSRJ]A/.j30=`
*fRZb@c#DH,i+.Z3G<GSG([/++fYq=^#%'QU&l3Ga8*\'L;$Ke2e(d[?MdH&FH^Lk3n0i5Ff
7YJl;36se=d@pW'_Tj:kq*]ATaq)]AG[2!5\lsH!Y.%AaSQKTNh,+"KXB>@WT_CQ);u:k%iLt[
=e_@?J_6+I:KKA)lXmjM<2X*0DpVe`Zq2n%9DR^e7-N+#~
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
<![CDATA[渠道目标达成率]]></O>
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
<Attr class="com.fr.plugin.chart.base.AttrTooltip">
<AttrTooltip>
<Attr enable="false" duration="4" followMouse="false" showMutiSeries="true" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<GaugeValueTooltipContent>
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
<NameJavaScriptGroup>
<NameJavaScript name="当前表单对象1">
<JavaScript class="com.fr.form.main.FormHyperlink">
<JavaScript class="com.fr.form.main.FormHyperlink">
<Parameters>
<Parameter>
<Attributes name="area"/>
<O t="XMLable" class="com.fr.base.Formula">
<Attributes>
<![CDATA[=if(len($area) = 0, category, $area)]]></Attributes>
</O>
</Parameter>
</Parameters>
<TargetFrame>
<![CDATA[_blank]]></TargetFrame>
<Features/>
<realateName realateValue="chart0" animateType="none"/>
<linkType type="0"/>
</JavaScript>
</JavaScript>
</NameJavaScript>
<NameJavaScript name="动态参数2">
<JavaScript class="com.fr.js.ParameterJavaScript">
<Parameters>
<Parameter>
<Attributes name="area"/>
<O t="XMLable" class="com.fr.base.Formula">
<Attributes>
<![CDATA[=if(len($area) = 0, category, $area)]]></Attributes>
</O>
</Parameter>
</Parameters>
</JavaScript>
</NameJavaScript>
</NameJavaScriptGroup>
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
<![CDATA[月度各区域目标达成率]]></Name>
</TableData>
<MeterTable201109 meterType="1" name="区域" value="销售额" custom="false" targetValue="目标额" customTarget=""/>
</MeterTableDefinition>
</ChartDefinition>
</Chart>
<UUID uuid="c6066335-106a-48a0-a3ec-6f87d1503642"/>
<tools hidden="true" sort="true" export="false" fullScreen="false"/>
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
<BoundsAttr x="0" y="0" width="228" height="294"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="3" y="58" width="228" height="294"/>
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
<![CDATA[线下产品月毛利分析]]></O>
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
<![CDATA[m?m]AJ;ca[R?`Pd06DE&*#RNqmKn6H=+bbSI6^9'%`2-qc+s;MS$DpBg8@0iIYlPGo![`eb)2
BM7,)]A9j4qStqZ!%GH+G@.e-#=2:#rFbXVuK#3kfiqgSTjQ$S9+,mhK+.Ul!F\^2;5]AY1B7D
EIf"qV!8p"U!8)7$e,/tRmY1cW!2/-GLd$T.L#Y=TecrNbe$M\7A/k[F_lZGjcW]Ad$Huh=Ge
8?ce:4A<%G4r=c>@35cW:7>dq@&O(@rF#>ff_1B1?ct3oL7i?L)S^/'c(;.SBe.pX%O2=a(%
Wh.A8LhW,.d6bb1]A?Fi4$[T=RPB-bQ48&'0NAFO-JJj72M@om[e;X[rh5\9IUXGpuU,jLf\Z
9i\>jXi9cV^"$'s9[.#FIV'4di4C`.[EJ[Fgsm"4&=%3>FWtInIRVnG;GRqk>Rekd-r#t_a+
S!kFP'$$.qAbK(WdZMG_BsbUGCns)E<o2U3)c)-XsL@H)SIREJ<?`^UX1sB);E,@dH"EI!0k
)fs6MoQI\i6ILpA;2@o!]AIrg\B)<tq.Y90"]Ald,#/7Y-.ReVL8;ju#3S<:\;.[T@b+;_);1^
;YY4:OCFWi-KK>Ajh8<`+WduVL!9Z15+#ef1emKhUn.AJYrZhK6I6mbQc+K=oag2D,Mg/fbN
Ni,D[Tp:?>?),%Y1deC[96$V[#(UQjF$*DIm(_=JoFm$41qU$HPZ=HhlL:AnmqE^n+15>rTH
E4#so_Do3jl!e=C;cdJ;l9_^cJlcdUY9ELR;;fY^jA)!s$LJq;1,!]AnruX,,>)2)k%Wp:s<2
$T3PR3eR3X*A5Fdqq_G4l!c=.IJt.CW9Ei!`ec,tsp&^:%BJ1T,XeNCN8"s%AZP6.8h5C-Lm
aNN>u#jH;7$aY_OeV3S9cAQeJ7Oc[O81l`(3NQID<8(J%AW4>UT<(!gQDqaN7@Ps$1r?lG`p
BAK!ip)6.8<XQu%N7o%:G+DXPs9?6%qJXg1m599;E4juE2rjsMV'1jEF,@rg7?1k-A%XTK&3
D*NMaAbd>KIjkSeS]A*b-hImnZA5.\t/OFS/V"1(%h%GGNq5lY)NTGtpWQ":UG=n!Z(\AkC+H
MpmV6V[LiZB^"^^/L$(U=CA);D&dshJgOlM9e"&lP[5_LjNq^LWle]A?i=5/OSH8h$`QY#38r
b.f)FlG1Sslcfo=g^E>ar^U8d.`dO)_+QRC<aoYkIV7=8`ZAB/Nd:Rp9"=hp=G>.NcLfWC/o
6D%i)X\L-SnbLO[R="$HkNkgOMrH8\+;L?!k@$'V:^dO%pH4atUR(A-9H2Ig!R[X.eOofEX8
M7<#9'c+dF\]AF@gS;IEhV,KtDY`pLY"EHKX(kLVG1kfdheF50,;lBl_?7:p@op"#m0iY:>rf
m'e:7s&2n>I&>&m5?QrOL0>!%#IH.j6AmEJGIq.hal'2`>3F6.-a86M#4;G.X\'hmJ\]A,*9j
<+&O3?XVQjSX\O^K_`X:1G_WKGbpDJi8mDNeF4JkH(iV!"#i_J=H"l'\/Y0d!H;o>^RPB83k
AJ1`7BPA)%;!O?/"$+T_VTu\$IuEeu92+BjQ1VQ!uY@_:e:;s'r0H!*)gBH@h:ubVX!LKu>`
HGT]A@cVlj1%6c]AgjM6jc4SGcRf@"IoqY%DaA''B&t+<HG:b?qHD-$EJc#r-O&SO\SB;f>">b
=O_M>E[Ul8p[r18M5*'`L##YX,kU'n3j#eW/^,b;mlho[i#<tN9rP-KB=\[`>mt6%&5T*BSW
<F]A[2N%_G'+$:_+5k.qGKtWh<gc9n5>i3ElJ$5Zh;qp?MA['%G-U6Ye';[EX"TZO8ci[_Vi!
-_FL.717a7.007n@2)1>'LlLF7U[!#@2)1>'LlLF7U[!#@2)1>'Lr*q[#$B<fE7-/XFt>[&G
mRtG&'nL-2/Qijk3I`-INe@:Vr=qa2qdU1Nj?Phc1)enad24Q@0YErEf~
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
<![CDATA[m?IKLdWZPK.G+6gSiW^u7*;5i7]Ar#68XQjTQ5FdJ=[C<TQm%nIP'C-+jCOG6ZmP%CK[-j8P_
nN+Mdo54XAR7`')#=i)(GuMO9u*fAc2iq45\pZTC;As]Aq<XBr]AK'cpAchuETu2R&.$3/1h9A
r"L8";JN+WU]A[6M/kth_@5bJWTpB2O0jc&iZ*]Au;Gg*c0)>m8hd(44(EM?6_.IQ8']AmD/F4X
$_ds,7AE"3bL\Gj[TKV4R7.XN9f=V\%dC"(b(4D'mFC+a$.*+e"f]A:]A-th$B364`<IJ[WcV\
2Z6tM*<cUetV/A\l*#Eld&W?LKk\DFah(!k+R`p[_j[kec!od[g@lS@Eg/t6i*D1Qi_*ghPY
:a%o[*]AT+1fH7UHCqfiJP_Ce+"##1@:HCMdkg#XV!*;=OPEirS1e\E?Vi#MBWW6uL%Yni2=3
!6U#4?:l61$@BBB1lHU#OMFs&/(^*9.GS;1dJl79,<(?6pD4\'S9KcT9,(!K#d(1+YT%Z):+
TL(a:+>\Xu7`UmGlDB[N\O7`c!98[0A)&bOrcK$5bqTL_hL>"+sH5pp#Q,^F''HBbn81RRM.
TE`QWQQMZH\+]A&@ft\=8OdiS_(#a%W2lQ(/b=du?HR`6F&Lk((:7K/cnseKnZ57&;bFr!ah<
d0IoO/iY<7JF@?o-LH9m9>[/kjXNUj`L<mo7t]AFHCfKJ5P[ce(^,F)RVnn-^c<Tr4VV,\8&u
*QqhZjs*l0W7`,tmhGJc;3OfY?tG#t5M!"oVY\b#:*eECY5Ho>hAp$A)?fJ,c>`59;%dd[YC
#<_+?eAm[l=iZ(Fq6o)1eCDn=1+*\bWnGrhe(IqR<6(LgVjkX#(Y`n3M&>b+tRYi'^q:a5BV
J_aRqbACnr*Z?cXkk9?$iA/4HoI[[(O?Z[)AD@OL\F;X#-WUA;ao'@dBPM6[kWGNH/Rmg2oq
UV`j(Xupr7YY0.CXpN#l=G@P0eB=kjiHh^KG#[eFg&7(p4?EWVlb+Zm\,CjhOc.T%"Cl:7'V
aQALYnE_:l1uW>*$:#httYM[g#L/Se"OIO$e/J0ptCC6JI2-FAbMVe8C61iR^&1Lj@=HToh8
:D8WqV*'&N[BY)-B/Ne\CqLLUa?2@hBp(L\VWF<N4.XQ\Q6'HLEF<#C^STDAZ-/Bn0$`8,-0
i6>_j-ug[<0SO$g7ihaj&rX=eRTtAg!e2/?_(&89S:9mJY,NA'[#]Akrt49q,T/-+'R1NFg).
+RCV+Ob_qT'Ca7L?d5;Z=gi.+@\VgGYI@VL[SG\7"S(:Z/r!+sUbJ`9Ti;Gj21ok8n7VXNB^
<91sj]AJm.j9!0ImlDFpkNZ2EB!NkCc]AY:%>G1Rtebes#h9AbjOAO2eA/s)^'kYY66Yml7<lb
hraXW..alTl`K7Pc*[=2S<[*<so+^#l$'/fdlZC0!S``;PL]ARiSX#'2:X)RD&^V_Ps=3;6dn
,-Q]A!^L9R?I,AB%Efq&u$Bd?`e\b":]AHNk<'0@^<_YWRYior)IM(Z)Gbb+K#9H2u^QIb8\d#
2U&(baaW_lFr`>#W=Y&X<.r*(qe\@"Y<;eVua3i3rH3rofQhk4bHIhW4+LP)gY!5i!O:I<*f
6jKW""TVV<Ye3%p8M<H_O"f^hpoufD2a9]AW$%Kl+cTR^fdhXrIAOU9O\DtumO$-D7cNAbPhM
G8?Oj-,3un[S@)KB1'-XfR#o]A;fcJf!)T@d4fgBmirVFM&_l>Ieb@)[sj:Cm87&A;:6.@Ys>
o6XtF7+.1TCHn]A\M4#hkcMe(kr('6-B2KR^dtF3VgOh$cl70R]Al><:3Q*B/_bDNq5dTlg@_p
S*m1e4;[%#7ugft(HS.j5q]AFe]At75)#SE0J@Yq?ig`DMD.q#ei6AuZj]A?:b]AI3LpCEpXCL43
ZQ`OJo^!DQL'(PuWLAWBot@Ytq6>E"E1M&-YoB"]A5g7;%Nn.&-YoB"]A5g7;%Nn.&-^J]A2Tj>
+a"Zkq'sk]A;S_J$HFp^E'rB.!#,g)_;BP8e2"G?`@i4Qj&Bd"Hf\8U,Um`"Rmrq=j,IfK~
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
<![CDATA[= MONTH(DATEDELTA(TODAY(),-1))+ "月线下销售排行榜"]]></Attributes>
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
<![CDATA[2024年榴芒一刻线下销售驾驶舱]]></O>
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
<![CDATA[m<MbuP?HKi.Z0++S,nm5%`8^6<(Dm4#bRlD,"2V;Bi,Hn#a#`$JKu]Ap2TVgf:eF2k6VHX:-*
[H4)C:JqPUJ9)&0O;1D^WaKrP,scm`rf1]Am7fTce`H@[J&>#?LOHF?>^_6mp*&mV7#jWO[CM
'ZrWZ1Bs$r5]A12B<F&fB*QBkhUd6e0:P4E5)f4A)O&YEPDY5j7RVo.lhhm[M/%rN3_h;hc7p
X/te5V,$6d0M7PLq+(;r6TTR#A/bR6OmnXs)`\@O55,2A&l'KdqProHhErnn;-`=8r,.`ij`
6,M&amOQlZe'p$d`?N?]AQJklf.YS9JJ4f+BT=X1RZ-NETL=\eFTMV5pd&M,mnnZg'BIS_eSf
TpE_gltXddh17-Ee!D>GR`CqXc[XO:I=6Qu#'5'JfpS/LR"9Og"UPmJ??Geu'fH0GUguH5cR
eV)+M]ARIj<scI5W\(DLV$'!C!l0)$e!heZKMa%Il@!nMK7l.s-C_iIY^HTkBK[:FRt]Ao]AY`Q
)=1MSrHt#GZ;djG)3:oOYJ^\3Y]AU]A[D@?d9A03iWU,?ruO.6/^\->DmUbYf,u)]A)[g;G$_<T
SFbM39EbHOGAM[3M!lk6G+\0o-ds'%VSPr"]Aig))W-r(!EqU7a.%BLF(eQ:b>Yl26S(kAa;?
AsY$)RHDU^ZAM+*u>KfP>.5bqkKBtSXkkj*nZnMQS/lF?!3bq7IhZ^qq)8QM@_,6]A'[:u$mF
/Z?.Eb9"Q4aO$nhs!5U$l;7Bb7ldDun`sX>P"pGYLfC1c/Hs!NQ*ceoP,^.JL\/l-m[4e:mP
CAJ0O[T`g1G`X>:Z6F49)_dR:=c#i*Dq2Y9W@7DCo0<2XtBOq\*:j!K%L:nTVNG/)[6?/AYs
3\p1Ib>]APdf&=p@pgBe22/,q`(GBFZJ-sL\gKGFm;Dkscdo]A$4'9GdI1r9.L+*t28]AGl)t$5
Am[%PkNt8\qCd;F2u:_?p(X]AhRMccp6._V<.=6\moRXoHuE5+?2tRIZN#"pfG[,1PL\-/n4A
F0:n^9X*emHNSX"L^W/fjDbH#36GDNs.[J1(MA`f,MCOmmqBhF$CKEQR`PtX3b"^@:@8j!UK
)08)V=fMp((5mUVYI>:?X.1q*_;bhS'B.gGl)?N*b%rT;rAIR=8+RAen*@?fY'(!)nQE)QHc
qZr;qt%IK.RDWBSq`4GeNHh(qOJ4CRnh%PVN'6Z*E]AYc1"eXIh18CQX"8i7mN#6kFq$IaB07
TKK4i`3QPo;Bc:qPG"-G96]A02)?NcP^`b/"Rd;8pKcFBlY6c7Dd-FC6l;be(EOB=`[367Yl4
O_Y-AF<KTYC`]A?Xqo0J,5D%@2s%nANimoCl;>^dM:A=B^8S0r.>ki7:ng/Z$KjBC;e#HKBJ<
SZp`.u@.B*4sSls7_cb:h#=K,F4[3n>I/n8Hgh%W;IIg?ER3q/X53o"e;Ct(81''E<H4Sia,
Ce?HUJ(joL7ShS.Kc8:T\O@'l.nBCWAc)s.O%OTsP\n"`"q:16WIbIQ72B!dmel=`;4rhB+!
pbO5MtrW9Y?XcR;bRDH_F3e^p,;c@j-u4-3U"G9Ek@!r2FmpnRTO\4*OS2JSJkb\An#0E9;@
(,RMm>gU@)1hil;r&eo4[31oKD;^e@'hscp;\+j3?M;F?KW'o%R]A7n^9QtJhaCeGkH,YAIT[
NRU;[m/0cbOh6;%7*KGgT&.%.6$_L*+l6PN'hOmAbDGm)G"6Kie=kEYm&?$KsbsEe5Tr>(d5
IL>iXi\5OPt'0<'R]A>PU(<K(1u2i9['[RpKARWkt$TiDL>P'e)G#$A0bM%Jn+7OT:1p`gM=;
Y[N;)^k:B0RuU=-QnA.=S(8SY.oSEO*8NU.;NlD*Uqg3bd0=1%I9A.4L$e7sH;&4s]A[VkdC5
XA3S4J+TT?JQZk!;80AMGSo`B)#L-1fDq@s49JkEcgr9Por'R,/INSs.1/XQN"qLI`7$O`Pq
4B?#hrf^1blP':[m9JdqEH]Aos"8ImtXjui_kbu*`UE`+tlOX(oYWiCF"F<7LWT/b%-hASD2P
m6!DG"'?^h^#;B)D"LhZ6]AID/NhG39`J?tS,'%Bb;0-@=VWp:7_)p!_*sOjK1>,k0Dqm2"=F
jF!#C&[VEYkQ)Di[R9b&nd%tO/h&%Zr;p^)8@<9"+Y9]A'@oh%8oq=qitlPun4\i>/-81mnI*
ZL_mSW8$Z8+b986?o</<?dKg92,Ut=`@L7p`dknt0.t2e.a#DDNn]Am5.DHC6Z6rUGCjpn$KF
8iR>CS-r7@aRQ<r9"b'1slkIkfK3D_mP8GPspj,o`H8Z/G9AU,.:2#inj$"ndG?NT+hC6NQd
l=Xo)nMnoaV'pSWLa_D.l&j3Og)O(pN6rYae4Fl!Ae)]AW+qiA4UkqoH]ACjOdi^0*'Q>4IgI-
4%ktW>WU-O!./Mmhr;YE#?Ba/4GVnh))5=]A]AT@+F3>!5rl67U*Yd:P=64%)!G#IEDFIa%$nS
&-8FQD&dmoLa7WKmi$h;:Va:8GuXrY)-S=kB@]AR!)`=03+2hb$qXGi\/(E%7994ICN[;j8E$
Lih[2*a?qEb`mjnlRU9,$Q'8aT]A(bH>SpsFBROM$1Pbug/6-t(kE^<eK8")`R/`!G55Wc?1.
9l=\^r+C?$+YUfoK4XG;AS8r#CMa#Y-Tj<$hR<d.f_Xo6FBH8DHek<*i15@*5Me#sR6\'&.t
.48238D=">Rb(,d^o?e4[XDSWh7A4q06r&R7OC,e2>;1!A`qp:GQU8RPR(#O=`B(,D?5G(cR
B]A#Ja.C,SVi7Ve:&5lfMorEsNj[iXK(thlMYiuFL+ueV2(mlugdQ$;g1Jn!F'#5=3b=rLlPQ
'2+67Bo/eDll&dI+95#keX[[!kMWCZ%?RP@tn@]ATpZ</h8T8#=un$g*.93RBKK]A0gVd]A^:+=
*!]ARe\(t1%o'$VKar.%:C@&\"r!`Ps_Lc`D([=o%quUsf9Y1%HVY*VROuk]Acj,/))^h&=6J4
XJOg]AW*K[DqFe5O88an(FecR0ebl'Y+(-]Ak+,]A,IItjSeX.FR3KpIjP1`S!sNt545o1ZF!*U
T$e*-N6IRolc=Wn"#oqEeCDGKkBu./s?IVr!Ddg!BH_@Z1_H.*'qlDCl:I7#P>?iQ"9rFk#I
6ki*+;D66cMNa:*_b4M"RT7q3oF3d=U3EB@UPGIP'q3]A;W!;Xo&QobYBjCOi"8gCHR]A-/d1G
SBhUs)$H_]A&f$pdZ;5&K7c9DuO0eedUN9-i>(4>ITp5Sp6;>mWAMH)O9PNp@Z*U.u_K)Bn'r
lKS-5YtgpT\,I?.VsZ_?c8G)"6m'"9I$G5i*fq@r+4.T`F<mm^;EZh8OX^,a,AO^XgH:4KHV
&N!6c\4r7=PHZcuU]A0Zmrg0%;ajB?o.jkCuL[rn$[Qm2`A&eN,btWCLenX@DDfI"b%LcB7S!
Nqk1%j51u"/Jo-8XG6FOgT'&i%H_AR(.0!$7_D2FhgR*8rrND1_7d8(8!]A=AN#X[in;=/]A=3
:?5%jhDthXW([6cK2;_QirXU+WFBC6^)kYUg7@pXY[5!*VD#`%%1,RQf[bY!R]A&*ba+cS*WH
*j$H"$g(a>_MJAG]AaL-03b=a!simW-F'3Q>[&muqd(i)/GH[h/2CO(311E9eM#Mg/&nPAd'&
hF;O.9!RBlQ\k8!^9-La1YER?<G-,8L8K\8%:cA)@.eI;YuU<rP!;t6qUB*TSF4anlJI^O;T
ZbFE/IMC>ao0.3]A]AkB:W_GFXN2).i%&.j'6V2p1&)Hf\Du33A:cO!@`$V2HLS2uDO2$SKakP
:Qs;XP-?L$TWJfBFaY"QOl;m^o<H8>Q.uP^FA,pr9pFIj0<^J?HE=X4c\g+OE.tQ$rqn/`H`
3Io[Zt]A)C?e0G4a!>g$&&3#HOh9DH[_bab$i:`V\qG"eW!V#T(hZmHcgB''fK2iA#_Bi/!ZS
s6!TR@GZ_2is9D)e3&UH[/@@B;:j8V#G1m'!@@DW3Oi56n@m&%l7BJ:#G#0[?SV#*E#41a`\
KD$&OZ2UdoJlS]AIV(MI8g<]APHr-N'H*hdtoUG@9VZ?)'e7094iS;]A4Vrh;K?kLE*6#TI&C0;
TbH8';fs=3*kRe8HZqg;FYMDS$/k$h"R;64GUC<R_R2GZtgA5)\=P./J9m7he!c18M[)(_8h
YY]A'Vm0%qZ)1\?DTqVNaf,Wokd&f^ON[T_CE&,#H`5qjL-[.8<q)7#>Fk79DFML8ubQmRpo*
o03<AnE9]Ab.aL=noUR,n0\q37m!?u=e.K73(2WujZGm%EJ6i[;E6>F.1VU&)P30[!k^"%K]AZ
f#k;bt-LEr.TF&o$6fRcS.eqN2T/fH31dH9X'H`TC_LLW<d$Y*0+(-F*F\lV1Y$`Imp_tJM^
?ULQso`Ts%h`k%aDWg*?lrIPXFV"X5"u"sq0Se@clD.K+"@q*C%Jup#Ed]A%IcLHUON1Pjred
41&b,nJ<7C-H?:[N=E=.t2[=fTf&TY5ZnJM*4X"eknQ1q:V[H(O5Jf`pKfS.Qo70`toh_g$G
;c'tJn3TDPgL!I#hdY+/G'>n9n_2"KS_Z"QoKVmgM2a;#QTDd"Rb#a?L-6^!Lro-['<>?-H?
!1B7^X)_Th!PVCekC$IhDG;RYiA*EmAZ:^1LY2=G1\7L0+0_VjJFDCYGDYbHe8,\R3KY2"K5
KqIdLoEJTG&KT^8-.RaJ>R%n'_2K@\[fRRg?or#C.53kjdRrdA*NkuT3;jqF)1EduR)>Peoq
kQ[i<rGRrN1IVEj)rVmq*!V5OED`<^@h<Z%gt\cr$8YEc6Z`^5M"I-EjjT:QdTYRQeTS]A--2
7'aoFD;Lqb2O4Rm5(1HXi'EqA$r.]A):P]AW$.E-8g$k_L[/)aNX9kCi$;)B;fI3S1O'3oq12H
Uq51/e'=5(0j/VU/EOWU<-WpVe7L)LIfi^XTL7dX*Z2S"B>;+e9<F7PZ>B,e]A=54\Fqi)r1R
nFj5qRsF?WYQ)Y:Q,A#Yn5T`UmeR\c5L9!G*h7n6'UDr5<0X#o_d1mKoGo'hUjJ@>%/%4O+^
M!5]Akq*4+G&P*KkoBnDM+o@f\NO]AQ`df?*Q[QMH?f.-B[H:rre>pqBgi?(Xn:AJ=Gk'N%d$8
dn_6iG>lPHnn1*ZIE4jIMa,Dr(%@]A^$TRf7ilRaM'97/,E+sCC#?$aPHCYm_:-otASuiXnO_
=6*^7#"q:L&USX]A09ZNTa9Q4%[Y>RdR#Af4>g]AQcqe_mUoS8c-q`k9Z('X?5]AkCO`!/EI\j=
^[TRh_.'!A\o/8Jn-*&&aaEt/!_'V:2%It'k%oOjhJQ,1bJKY5qZR1ca)q.XocTa9]AUi2Ip5
/\NqW%E&$65[=T-p.Yj&qj`]AHtjp&^]AM,P<@YDiLi`5e:t1Jm$/lr>!@,b'$@>a9^-1]AJpE!
@WKE&$o4Z`j`Vr.R?]Al+_aXaAdelqh4S#jO(kY4+B\8I<=J'QZ+7`d>AJW\'Tf7Bjd#k5i>9
h>Y/u%<[PH13P,Nc+3QRHTnj+fJF=jf`(eRk$=sf$oN#'$)9_=q&&hQ$Ur69^QEsE&VaUGZu
jJH<+j-[l`Ermp)!cJ`RdP:;43\/mShPdEf"?'<FL*Wn=mL1kM_OGlI^@)4Z2Fh)I08kA%cN
&4'\?#atlRPR?<U-HL2E[VJkf,7FlK,\NZMt*!_'BQI=%87#>)!qim;;M-7+^X3]Al<k^Y\WL
*(=!27r5Sff^[3@'d<WM,_sQ(-OOQN?&jUkm'24OiT>NpSui4^'9E7P!B#UJPGZDc)ZA4h_,
P="Ab=6!'=7t,4-K4pG2;Oeiq:_>_=,AJ;f!=A1e^6+7@R^N!t1&eobUp&En:\+'kJg=oWL'
=o$i$A1gC-gJ!f28D+s0SK^gR&EqM>Z).$]A%qa<'+l,gL=[9@:-h]AqiA#`ur/C^k]A+ogg@f5
[`>9]Ab[6rPXsgjZ'5M0el0QEjS2N$lT]APVD#l0+57FVWd]AH+RBVbO^ujhsmSmQ[K"\SnDnIP
^(L(%"hoQB+e^.!onQI/<[ocmRmSH/ai7-6;cT=S8NkHo#.]A3]A-JmtNN"@`C5#&B!(`-kYPL
EF_g[SJRKB3V%R>GZi6$:8Y;rr,QfcVJ,2'EE(jk,O&$),csK*UMerN=o\RX#6F4DS0BLbX2
?qrnYYPb;VED`<e)IF[%+qK5KJQLqZH(B4'ktB>c?WQk'EC]AB&2P$orX5%[Y5kIH58+;XI.7
Cj<hc<(]AQN5:ePs%0\b"9);jT!Fboo'G;^t-<QfJ2R#S\jkYYg=&85#TKL*ANL)f,mprttD4
UJf)Wb5)#el/#L4[/l6m&%VmlVTG]Am^m8^!Pj.bZenqHjsYuMcJdcER]AnKY@,tK0g3;rqiu/
a=apA9'OEQbdkQRuNV$1g@b(j%$K^=;$k6Wf:ZHqFmUFBjqio@,/0d@(D&k()4dmsb9uN#b2
B0-q`ODVtA$Qk*U2bb2Lk[B#):0G=&@%BTQK11DKoQHY2U-.\jnE^SHt</f@$I!onqNc0T+=
590^G[X(B^RdA;HGWPO34e-GlsHr93!Eh1a/>"h`YT@I=eAQn=ZYbV1CuWHHk4:Fgb4Q(&hT
H]Ae3f\[q-nEo5UCnT6;<Z0sm4?IZ`g>2'kBGa'^FH"2raVfCV7g-:SWZ'4ql<=U9!;i%b+43
DeHCR(qjY'M9G5.*Q88gXN1,a@2T+.l)?&2`iHnE<+trG[qEC#%DXTPr&QaTPpO]AU!/$Xa0f
iA[/t>dY*FY_4e"PqkW?a.V2]AGS]AmZb(\Q%QV<g1`F#oF7(2l&2UQN4XY,S)[1SZ>n`*7,U#
q&`aT;7/PhB:B!<L!m=:n1GP"=D*@Jp3$/ad8<H7,6u`"]Ab>t"@clM'NTUUo&-Ch.R\R+eDm
oW`m1k6R4L![^VI+F"K\Oc\0H!-;9g\A.5X`uC9q!eN*R#%h5/#O6anM_J_R"arCrNNl+p.0
]AmZIXgl@WD?XCB8A63CF:F)gBJXcWLjj+Z%4$gHHc]AMr(lWt!KSbH!`P$;8u>\RuGWi,[J]A>
j$GX(<CQmjkI=h/s6$b12TY+2BR_ZQl%DHr8XGVJfpJX$l(0>KsXbqk&W%l;88ci4KpOk&pk
f#?-=R[spX&jDk4#3e+N5QS+P)cq$eBCA;Os$.q:Mb*l.qn1L$-(l*@H*ilt,rMkkN'8+us@
q&&qF%HDkfZ/.6H#3pM*FbV*GlG\.hfRG`8>.k:p'U7NjR4]A)2t5K@@Y5h-@MqWq'5+W(j8-
6YrsYC#Te(4V1s?niLsKZ!.tRUYi9cLS-,Z2!lT4pWc@"4U-W!oS_E8]AGR5Y_B-qNPMhp&d#
P&Q;`NQ/-:Q#fd$c"PqYY5`BH+K<H!WDp(2Cb#8ubYU,Wc-`$l'Tgqd]AG,Te.s5MR%U]ApHJC
)pkcutt`VSDY2L8=&r672WdZ,GbucoPbA>Kkj_6BEJ!<q'#G/Jj+rLVg$NB:@5;4(&!5E2K:
q!7Wtr[E'Qt+GoFq\p$mB)8m,.M\>k-F>2!Ubk#lTJ!oIr(PUmRmu,P\m9C&J>#a)/`M9'dm
Q32M*6jd.S^.*J+4iFsMe=iC]AU_HK\:47LPqY=Z0Lf3iqXcX[CsSL*LPL9!RG^*O#7)(@Q:i
HNF-jr"qs`=X$^Jf;rBt5B24oTBK8`(s+]A--MS"K^!RVVYFif53:dESTZ#1M"*96'<Joq;9%
A>bDcMaTIBPLaL!qVkmYnp,[hn@TCjK*\aTqA*[dqg*J20@?a!Aa1Oig=F(bCTOs*p5IEQj8
N0F;qQ[rabQbBQ/<p3(>-(SNrC""TbJ2+'2h7@b``:(360ejFB\%?hS/lV415B,m@'BDZ7/.
8i&9DTDmha4+HUd7>DiAgBKA%q^tqeH(?S71h-^*$bE>7[XO#[jh>>GOSH]AgI!nXe0"K[Is3
K;t5N0s>C!S4J=,f]AGPh5c=gVV+.,b.J8Ijq0F$1Aau@Zn1O#pU=KD>:))c8lJcJ,6t7Gk<J
'E@D,L8;NBkD<=r.$f'NBSs#q2*Z:r/3VQ-+@PM$nYd$9`iX]A(hP9?\I6YbVE?6hn'&@Ukk_
R"(ZL_bBRM"$(3crqh8J?Y;#a'6q74!h@_pJ[c!q"fBQ-+9[TthW+3@p;WK1rA+Sm=PT7n-m
4-%e3fXeVRcN9ErNM;?F>j3LL9kM3D/lh?LUa=J'X^L`J$uXoSLA2C[")OHmoKdY0TUk\nbd
4;Z)C=ijsR0^W(_Gs.Pa\<OP#,ld@]ADb)#(n/R>g$LR*agerNs,eJTs@)rE4^0!qc&f;'b<[
Db:%Hg1OMSYafKepko1c@T5'CX(X90&<-OK9sEti+;C5GT".&?3W'8Qbgl'AahI")8$Aa#6-
mk^JI9GS,R-"X[LG!DS*?ZZKRp(eIV\F]ADpXMDMru_/IRo!bJIiLZLIm8iVHtSabT]A5Xb<O[
UPHMmiVkfbrI4h~
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
<UUID uuid="12554bb5-d466-4c82-9516-df74d24887c9"/>
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
<BoundsAttr x="0" y="0" width="271" height="228"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="681" y="67" width="271" height="228"/>
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
<Widget widgetName="report00"/>
<Widget widgetName="chart000"/>
<Widget widgetName="report4_c_c_c_c_c"/>
<Widget widgetName="chart0000"/>
<Widget widgetName="report3_c_c_c_c_c"/>
<Widget widgetName="chart01"/>
<Widget widgetName="chart0000_c"/>
<Widget widgetName="report3_c_c_c_c"/>
<Widget widgetName="report3_c"/>
<Widget widgetName="chart0"/>
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
<StrategyConfig dsName="冰粽月维度总销售额的副本" enabled="false" useGlobal="false" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="日维度销售贡献榜的副本" enabled="false" useGlobal="false" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="BI" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="日维度渠道冰粽毛利率的副本" enabled="false" useGlobal="false" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="线下排行" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="日维度销量贡献榜" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="日维度成本分析" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="冰粽年累计销售额的副本" enabled="false" useGlobal="false" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="京东销售额以及达成率的副本" enabled="false" useGlobal="false" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="五大季节品" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="各季节品销量" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="月维度业务员目标达成率" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="年累计销售额" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="热门产品TOP10" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="时间维度销售额和成本" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="ds2月度人员目标" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="BI2024总销售额" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="月度区域目标" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="月度各品类销售额" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="冰粽日维度销售额的副本" enabled="false" useGlobal="false" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
</StrategyConfigs>
</StrategyConfigsAttr>
<NewFormMarkAttr class="com.fr.form.fit.NewFormMarkAttr">
<NewFormMarkAttr type="1" tabPreload="true" fontScaleFrontAdjust="true" supportColRowAutoAdjust="true" supportExportTransparency="false"/>
</NewFormMarkAttr>
<TemplateIdAttMark class="com.fr.base.iofile.attr.TemplateIdAttrMark">
<TemplateIdAttMark TemplateId="31dc8673-ef37-4837-8e01-4fc1dbdb3446"/>
</TemplateIdAttMark>
</Form>
