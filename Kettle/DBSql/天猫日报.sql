with
ztc as (select 日期,
ifnull(max( case when 推广类型 regexp '直通车'  then ifnull(花费,0) end),0)  直通车费用,
ifnull(max( case when 推广类型 regexp '直通车'  then ifnull(总成交金额,0) end),0) 直通车产出,
ifnull(max( case when 推广类型 regexp '引力魔方'  then ifnull(花费,0) end),0) 引力魔方费用,
ifnull(max( case when 推广类型 regexp '引力魔方'  then ifnull(总成交金额,0) end),0) 引力魔方产出
from sales.ods_天猫_阿里妈妈_万相台_基础
where 日期 =  '${do_date}'
group by 日期)
,wxt as (select 日期,ifnull(花费,0)  万相台费用,ifnull(总成交金额,0) 万相台产出 from sales.ods_天猫_阿里妈妈_万相台_内容营销)
,ud as (select 日期,ifnull(成交订单金额,0) UD产出,ifnull(消耗,0)  UD费用 from sales.ods_天猫_阿里妈妈_unidesk)
,zb as (select 统计日期,
ifnull(max(case 	when  类型 regexp '自播' then ifnull(种草成交金额,0) end),0) 自播销售额 ,
ifnull(max(case 	when  类型 regexp '主播' then ifnull(种草成交金额,0) end),0) 主播销售额  from sales.ods_天猫_生意参谋_直播
group by 统计日期)
,pfj as (select left(时间,10)日期,sum(substring_index( `金额/币种`,' CNY',1)) 赔付金金额 from sales.ods_天猫_交易赔付金 group by left(时间,7))
,yysc as (select 日期,支付金额,成功退款金额,ifnull(支付金额,0)  - ifnull(成功退款金额,0)  去退款销售额,淘宝客佣金 from sales.ods_天猫_生意参谋_运营视窗)
,cb as (
select '${do_date}' as 日期,sum(quantity*含税单价) 吉客云含税成本  from
(select
distribution_channel,item_code,quantity,delivery_time
from
rpa.ods_01财务_rpa_吉客云_销售明细单数据_日维度
where
date_format(delivery_time,'%Y-%m-%d') = '${do_date}'
and
distribution_channel regexp '天猫旗舰')a
left join
(select 物料编码,含税单价 from profit.人工导入2405组织结算_无合计 group by 物料编码)  b
on
a.item_code = b.物料编码  group by distribution_channel
)

select
ztc.日期,ifnull(直通车费用,0) 直通车费用,ifnull(直通车产出,0)直通车产出,ifnull( 引力魔方费用  ,0)引力魔方费用,ifnull( 引力魔方产出  ,0)引力魔方产出,ifnull( UD费用  ,0)UD费用
,ifnull( UD产出  ,0)UD产出,ifnull( 万相台费用  ,0)万相台费用,ifnull( 万相台产出  ,0)万相台产出,ifnull( 主播销售额  ,0)主播销售额,ifnull( 自播销售额  ,0)自播销售额
,ifnull( 支付金额  ,0)支付金额,ifnull( 成功退款金额  ,0)成功退款金额,ifnull( 去退款销售额  ,0)去退款销售额,ifnull( 吉客云含税成本  ,0)吉客云含税成本, ifnull( 淘宝客佣金  ,0)淘宝客佣金
,ifnull( 赔付金金额  ,0)赔付金金额
,(ifnull(直通车费用,0)+ifnull( 引力魔方费用  ,0)+ifnull( UD费用  ,0)+ifnull( 万相台费用  ,0)) 推广总费用
,(ifnull(直通车产出,0)+ifnull( 引力魔方产出  ,0)+ifnull( UD产出  ,0)+ifnull( 万相台产出  ,0)) 推广总产出
,((ifnull(直通车产出,0)+ifnull( 引力魔方产出  ,0)+ifnull( UD产出  ,0)+ifnull( 万相台产出  ,0))/(ifnull(直通车费用,0)+ifnull( 引力魔方费用  ,0)+ifnull( UD费用  ,0)+ifnull( 万相台费用  ,0))) 投产
,((ifnull(直通车费用,0)+ifnull( 引力魔方费用  ,0)+ifnull( UD费用  ,0)+ifnull( 万相台费用  ,0))/ifnull( 去退款销售额  ,0)) 付费占比
,(1- (ifnull( 吉客云含税成本  ,0)/ifnull( 去退款销售额  ,0))) 毛利率
,(ifnull( 主播销售额  ,0)*0.2)热浪支出
,(ifnull( 去退款销售额  ,0)*0.03)佣金聚划算
,(ifnull( 去退款销售额  ,0)*0.48)快递费用
,(ifnull( 去退款销售额  ,0)*0.04)分摊费用
,(ifnull( 去退款销售额  ,0)*0.027)人工成本
,(ifnull( 去退款销售额  ,0)*0.06)税额
,(去退款销售额 - ifnull(吉客云含税成本,0)  -
-- 总推广
(ifnull(直通车费用,0)+ifnull( 引力魔方费用  ,0)+ifnull( UD费用  ,0)+ifnull( 万相台费用  ,0))
- ifnull(淘宝客佣金,0)  - ifnull(赔付金金额,0)  - (ifnull( 主播销售额  ,0)*0.71)  ) as 盈利
,-- 盈利
(去退款销售额 - ifnull(吉客云含税成本,0)  -
-- 总推广
(ifnull(直通车费用,0)+ifnull( 引力魔方费用  ,0)+ifnull( UD费用  ,0)+ifnull( 万相台费用  ,0))
- ifnull(淘宝客佣金,0)  - ifnull(赔付金金额,0)  - (ifnull( 主播销售额  ,0)*0.71)  )
-- 分摊
- (ifnull( 去退款销售额  ,0)*0.127) as 分摊后盈利
from ztc
left join wxt on ztc.日期 = wxt.日期
left join ud on ztc.日期 = ud.日期
left join zb on ztc.日期 = zb.统计日期
left join pfj on ztc.日期 = pfj.日期
left join yysc on ztc.日期 = yysc.日期
left join cb on ztc.日期 = cb.日期




