drop table if exists dw_吉客云销售单明细账;
create table dw_吉客云销售单明细账 as
select order_no 订单编号,if(right(online_store_order_number,1)='A' and distribution_channel='放心购自营-sz'
,substring(online_store_order_number,1,length(online_store_order_number)-1),online_store_order_number) 网店订单号,
case when distribution_channel in('零食放心购-sz','榴芒一刻零食旗舰店-sz') then '榴芒一刻零食旗舰店' else distribution_channel end as 销售渠道
,logistics_company 物流公司
,logistics_bill_no 物流单号
,delivery_warehouse 发货仓库
,customer_no 客户编号
,customer_name 客户名称
,customer_account 客户账号
,consignee 收货人
,address 地址
,item_code 货品编号
,description_of_goods 货品名称
,specifications 规格
,item_barcode 货品条码
,quantity 数量
,unit_price 单价
,preferential 优惠
,discount 折扣
,amount_of_money 金额
,cost_of_goods 货品成本
,unit_price_after_allocation 分摊后单价
,allocated_amount 分摊金额
,amount_after_allocation 分摊后金额
--,untaxed_gross_profit 未税毛利
--,gross_profit_rate_before_tax `未税毛利率(%)`
,delivery_time 发货时间
,creation_time 下单时间
,amount_of_money 报价
,null 订单来源
from rpa.ods_01财务_rpa_吉客云_销售明细单数据 A ; -- 稍微清洗一下数据
CREATE INDEX dw_吉客云销售单明细账_物流单号_IDX USING BTREE ON sc.dw_吉客云销售单明细账 (物流单号);
CREATE INDEX dw_吉客云销售单明细账_网店订单号_IDX USING BTREE ON sc.dw_吉客云销售单明细账 (网店订单号);
CREATE INDEX dw_吉客云销售单明细账_货品编号_IDX USING BTREE ON sc.dw_吉客云销售单明细账 (货品编号);-- 合理的配上索引
call sc.pr_金叠修复(); -- `sc`.`pr_金叠修复1`(); /*补足网店订单号并清洗数据*/
call sc.金蝶补网店号();/*补足网店订单号并清洗数据 历史数据*/
drop table if exists sc.dw_金蝶销售出库单;
create table sc.dw_金蝶销售出库单 as
select 日期,单据编号,客户,发货组织,单据状态,运输单号,收货人姓名,备注,联系电话,物料编码,物料名称,库存单位,实发数量,仓库,含税单价,价税合计,销售成本价,总成本,运费,关联应收金额,cast(null as char) as 源单编号,订单单号
,关联应收数量,`未关联应收数量（计价单位）`,管易订单单号,平台单号,cast(null as char) as 管易单号,发货通知单号,是否已生成调拨单,订单类型,网店订单号,订单来源,网店没有平台来凑号,补主键号 from dw_金蝶销售出库单2 where instr(客户,'部')=0 and instr(客户,'组')=0
union all
select 日期,单据编号,客户,发货组织,单据状态,运输单号,收货人姓名,备注,联系电话,物料编码,物料名称,库存单位,实发数量,仓库,含税单价,价税合计,销售成本价,replace(总成本,',',''),运费
,关联应收金额,源单编号,订单单号,关联应收数量,`未关联应收数量（计价单位）`,管易订单单号,平台单号,管易单号,发货通知单号,是否已生成调拨单,订单类型,网店订单号,订单来源,网店没有平台来凑号,补主键号 from dw_金蝶销售出库单1  where instr(客户,'部')=0 and instr(客户,'组')=0;
ALTER TABLE sc.dw_金蝶销售出库单 MODIFY COLUMN 网店订单号 varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL;
ALTER TABLE sc.dw_金蝶销售出库单 MODIFY COLUMN 网店没有平台来凑号 varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL;
ALTER TABLE sc.dw_金蝶销售出库单
COMMENT='月维度金蝶销售出库单';
CREATE INDEX dw_金蝶销售出库单_网店订单号_IDX USING BTREE ON sc.dw_金蝶销售出库单 (网店订单号);
CREATE INDEX dw_金蝶销售出库单_物料编码_IDX USING BTREE ON sc.dw_金蝶销售出库单 (物料编码);
CREATE INDEX dw_金蝶销售出库单_运输单号_IDX USING BTREE ON sc.dw_金蝶销售出库单 (运输单号);
CREATE INDEX dw_金蝶销售出库单_网店没有平台来凑号_IDX USING BTREE ON sc.dw_金蝶销售出库单 (网店没有平台来凑号);-- 合理的配上索引
commit