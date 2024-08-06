with zdx as (select date_format(日期,'%Y-%m-%d')日期 ,sum(`消耗(元)`)智多星消耗 ,sum(曝光量) 智多星曝光量,sum(点击量) 智多星点击量,sum(点击成本) 智多星点击成本
,sum(加购数) 智多星加购数,sum(收藏数) 智多星收藏数,sum(总成交笔数) 智多星总成交笔数,sum(总成交金额) 智多星总成交金额 from sales.ods_猫超_推广_智多星
where date_format(日期,'%Y-%m') = '${do_date}'
group by 日期)
,ll as  (select date_format(日期,'%Y-%m-%d') 日期,
sum(case when 三级通道名称 ='直播_类目号' then 引导支付金额 end )  自播销售额,
sum(case when 三级通道名称 ='直播_达人播' then 引导支付金额 end )  主播销售额

from sales.ods_猫超_推广_流量分析 where  三级通道名称 regexp '直播|达人播' and date_format(日期,'%Y-%m') = '${do_date}' group by 日期)
,tke as (select sum(成交金额) 淘客成交金额,sum(预估佣金支出) 淘宝客佣金,sum(预估服务费支出)淘客预估服务费支出,日期 from sales.ods_猫超_推广_淘客分析 where date_format(日期,'%Y-%m') = '${do_date}' group by 日期)
,tku as (select date_format(stat_date,'%Y-%m-%d') 日期,sum(支付金额) 总销售额,sum(支付商品件数) 支付商品件数,sum(发起退款金额) 退款金额 from sales.ods_猫超_推广_退款分析 where date_format(stat_date,'%Y-%m') = '${do_date}' group by stat_date)
,ztc as (select 日期,sum(展现量) 直通车展现量,sum(点击量) 直通车点击量,sum(花费) 直通车花费,sum(总成交金额) 直通车总成交金额,sum(总成交笔数) 直通车总成交笔数 from sales.ods_猫超_阿里妈妈_直通车  where date_format(日期,'%Y-%m') = '${do_date}' group by 日期)



select zdx.日期,智多星消耗,智多星曝光量,智多星点击量,智多星点击成本,智多星加购数,智多星收藏数,智多星总成交笔数,智多星总成交金额
,淘客成交金额,淘宝客佣金,总销售额,支付商品件数,退款金额,直通车展现量,直通车点击量,直通车花费,直通车总成交金额,直通车总成交笔数,自播销售额,主播销售额
from zdx
left join tke on zdx.日期 = tke.日期
left join tku on zdx.日期 = tku.日期
left join ztc on zdx.日期 = ztc.日期
left join ll  on  zdx.日期 = ll.日期
order by zdx.日期 asc


