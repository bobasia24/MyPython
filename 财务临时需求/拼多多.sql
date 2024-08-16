with  jc  as (
select left(统计时间,10)日期,商品访客数,商品浏览量,商品收藏用户数,成交金额,成交订单数,成交买家数,店铺 from sales.ods_拼多多_商品数据_商品概况
where 店铺 = '${channel}' and  date_format(统计时间,'%Y-%m') =  '${do_date}' )
,sh as (select replace(substring_index(成功退款金额,'元',1),',','') 成功退款金额1,店铺,left(更新时间 ,10)日期 from sales.ods_拼多多_服务数据_售后概况
where 店铺 = '${channel}' and  date_format(更新时间,'%Y-%m') =  '${do_date}'  group by left(更新时间 ,10))
,qztg as (select  日期,店铺,sum(`成交花费(元)`) 全站推广花费,sum(`交易额(元)`)全站推广交易额 ,sum(成交笔数) 全站推广成交笔数,sum(曝光量) 全站推广曝光量,sum(点击量) 全站推广点击量
from sales.ods_拼多多_推广中心_全站推广新
where 店铺 = '${channel}' and date_format(日期,'%Y-%m') =  '${do_date}' group by 日期)
,bjtg as (select  日期,sum(`出价（元）`)标准推广出价 ,sum(`总花费(元)`)标准推广总花费 ,sum(`成交花费(元)`)标准推广成交花费,sum(成交笔数)标准推广成交笔数 ,sum(`交易额(元)`)标准推广交易额 ,sum(曝光量) 标准推广曝光量,sum(点击量) 标准推广点击量
from sales.ods_拼多多_推广中心_标准推广
where 店铺 = '${channel}' and date_format(日期,'%Y-%m') =  '${do_date}' group by 日期)
, mxdp as (select sum(`花费(元)`)明星店铺花费 ,sum(`交易额(元)`)明星店铺交易额 ,sum(成交笔数) 明星店铺成交笔数,sum(曝光量) 明星店铺曝光量,sum(点击量) 明星店铺点击量,店铺,日期
from  sales.ods_拼多多_推广中心_明星店铺
where 店铺 = '${channel}' and date_format(日期,'%Y-%m') =  '${do_date}' group by 日期)
, ddjb as (
select 成交时间 日期,sum(成交数量) 多多进宝成交数量,sum(`订单总金额（元）`)多多进宝订单总金额 ,sum(`预估支付佣金（元）`)多多进宝预估支付佣金 ,sum(`预估招商佣金（元）`) 多多进宝预估招商佣金,sum(`预估软件服务费（元）`)多多进宝预估软件服务费 ,店铺
from sales.ods_拼多多_推广中心_多多进宝
where 店铺 = '${channel}' and date_format(成交时间,'%Y-%m') =  '${do_date}' group by 成交时间
)
,zbtg as (select sum(`总花费(元)`)自播推广总花费 ,sum(`成交花费(元)`)自播推广成交花费 ,sum(`交易额(元)`)自播推广交易额 ,sum(成交笔数)自播推广成交笔数,sum(曝光量)自播推广曝光量,店铺,日期
from  sales.ods_拼多多_推广中心_直播推广
where 店铺 = '${channel}' and date_format(日期,'%Y-%m') =  '${do_date}' group by 日期)


select jc.*,sh.成功退款金额1
,ifnull(qztg.全站推广花费,0)全站推广花费,ifnull(qztg.全站推广交易额,0) 全站推广交易额,ifnull(qztg.全站推广成交笔数,0)全站推广成交笔数,ifnull(qztg.全站推广曝光量 , 0) 全站推广曝光量, ifnull(qztg.全站推广点击量,0)全站推广点击量
,ifnull(bjtg.标准推广出价,0)标准推广出价,ifnull(bjtg.标准推广总花费,0) 标准推广总花费,ifnull(bjtg.标准推广成交花费,0)标准推广成交花费,ifnull(bjtg.标准推广成交笔数,0) 标准推广成交笔数,ifnull(bjtg.标准推广交易额,0) 标准推广交易额,ifnull(bjtg.标准推广曝光量,0)标准推广曝光量,ifnull(bjtg.标准推广点击量,0)标准推广点击量
,ifnull(mxdp.明星店铺花费,0)明星店铺花费,ifnull(mxdp.明星店铺交易额,0) 明星店铺交易额,ifnull(mxdp.明星店铺成交笔数,0)明星店铺成交笔数,ifnull(mxdp.明星店铺曝光量 , 0) 明星店铺曝光量, ifnull(mxdp.明星店铺点击量,0)明星店铺点击量
,ifnull(ddjb.多多进宝成交数量,0)多多进宝成交数量,ifnull(ddjb.多多进宝订单总金额,0) 多多进宝订单总金额,ifnull(ddjb.多多进宝预估支付佣金,0)多多进宝预估支付佣金 ,ifnull(ddjb.多多进宝预估招商佣金,0)多多进宝预估招商佣金,ifnull(ddjb.多多进宝预估软件服务费,0)多多进宝预估软件服务费
,ifnull(zbtg.自播推广总花费,0)自播推广总花费,ifnull(zbtg.自播推广成交花费,0) 自播推广成交花费,ifnull(zbtg.自播推广交易额,0)自播推广交易额,ifnull(zbtg.自播推广成交笔数,0)自播推广成交笔数,ifnull(zbtg.自播推广曝光量,0)自播推广曝光量
from jc
left join sh on jc.日期 = sh.日期
left join qztg on jc.日期 = qztg.日期
left join bjtg on jc.日期 = bjtg.日期
left join mxdp on jc.日期 = mxdp.日期
left join ddjb on jc.日期 = ddjb.日期
left join zbtg on jc.日期 = zbtg.日期
order by jc.日期 asc
