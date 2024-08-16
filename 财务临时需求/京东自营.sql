-- 京东
with a as (select 日期,店铺,sum(访客数)访客数
,sum(浏览量)浏览量,sum(商品关注数)商品关注数,sum(加购商品件数)加购商品件数
,sum(加购人数)加购人数,sum(成交客户数)成交客户数
-- ,sum(成交单量)成交单量
,sum(成交商品件数)成交商品件数,sum(成交金额)成交金额
-- ,sum(点击次数)点击次数,sum(下单客户数)下单客户数,sum(下单商品件数)下单商品件数,sum(下单金额)下单金额
from  sales.ods_京东_京东商智_商品明细
where 店铺 = '京东自营店'
group by 日期,店铺)

,b as (
select 日期,店铺,
ifnull(sum(case when 推广类型 regexp '海投' then ifnull(花费,0) end),0) 海投花费,
ifnull(sum(case when 推广类型 regexp '海投' then ifnull(总订单金额,0) end),0) 海投产出,
ifnull(sum(case when 推广类型 regexp '精选店铺' then ifnull(花费,0) end),0) 精选店铺花费,
ifnull(sum(case when 推广类型 regexp '精选店铺' then ifnull(总订单金额,0) end),0) 精选店铺产出,
ifnull(sum(case when 推广类型 regexp '普通计划' then ifnull(花费,0) end),0) 普通计划花费,
ifnull(sum(case when 推广类型 regexp '普通计划' then ifnull(总订单金额,0) end),0) 普通计划产出,
ifnull(sum(case when 推广类型 regexp '京速推' then ifnull(花费,0) end),0) 京速推花费,
ifnull(sum(case when 推广类型 regexp '京速推' then ifnull(总订单金额,0) end),0) 京速推产出
from  sales.ods_京东_京准通_推广计划明细
where 店铺 = '京东自营店'
group  by 日期,店铺)
,c as (select sum(ifnull(总佣金,0)) 京挑客总佣金,完成日期 from
sales.ods_京东_京挑客_订单明细 where 店铺 = '京东自营店'
group by 完成日期)

select a.日期,访客数,成交商品件数 成交件数,成交金额,成交客户数 成交人数,加购人数,成交客户数/访客数 as 转化率,成交商品件数/成交客户数 as 连带率
,0 种菜金额
,0 种菜数量
,ifnull( 海投花费  ,0)海投花费,ifnull(海投产出,0)海投产出,ifnull(海投产出,0)/ifnull( 海投花费  ,0) 海投ROI
,ifnull(精选店铺花费,0)精选店铺花费,ifnull(精选店铺产出,0)精选店铺产出,ifnull(精选店铺产出,0)/ifnull(精选店铺花费,0) 精选店铺ROI
,ifnull(普通计划花费,0)普通计划花费,ifnull(普通计划产出,0)普通计划产出,ifnull(普通计划产出,0)/ifnull(普通计划花费,0) 普通计划ROI
,ifnull(京速推花费,0)京速推花费,ifnull(京速推产出,0)京速推产出 ,ifnull(京速推产出,0)/ifnull(京速推花费,0)  京速推ROI
,ifnull(京挑客总佣金,0)京挑客总佣金
,(ifnull( 海投花费  ,0)+ifnull(精选店铺花费,0)+ifnull(普通计划花费,0)+ifnull(京速推花费,0)) 京准通合计
,ifnull(ifnull(京挑客总佣金,0),0) +(ifnull( 海投花费  ,0)+ifnull(精选店铺花费,0)+ifnull(普通计划花费,0)+ifnull(京速推花费,0)) 推广费用合计
-- ,含税成本
-- ,a.运费
,(成交金额* 0.03) 平台扣点
,(成交金额* 0.015)人工成本
,(成交金额* 0.02)公摊费用
,(成交金额* 0.06)税率
,(成交金额*(0.015+0.02+0.06))分摊合计
from a left join b
on a.日期 = STR_TO_DATE(b.日期, '%Y%m%d')
and a.店铺 = b.店铺
left join c
on a.日期 = c.完成日期


