select '订单',count(1),'ods_01财务_rpa_0111财务对账_抖店_订单_订单明细'  from rpa.ods_01财务_rpa_0111财务对账_抖店_订单_订单明细  where  query_date  = '${do_date}'
union all
select '订单',count(1),'ods_01财务_rpa_天猫旗舰店_交易管理_订单数据' from  rpa.ods_01财务_rpa_天猫旗舰店_交易管理_订单数据 where brand<>'榴芒一刻旗舰店' and `date` = '${do_date}'
union all
select '订单',count(1),'ods_01财务_rpa_拼多多商家后台_订单明细'  from rpa.ods_01财务_rpa_拼多多商家后台_订单明细  where `date` = '${do_date}'
union all
select '订单',count(1),'ods_01财务_rpa_019财务对账_小红书_交易_订单管理' from rpa.ods_01财务_rpa_019财务对账_小红书_交易_订单管理 where `date`  = '${do_date}'
union all
select '订单',count(1),'ods_01财务_rpa_0114财务对账_快手小店_订单查询_订单明细' from rpa.ods_01财务_rpa_0114财务对账_快手小店_订单查询_订单明细 where query_date  = '${do_date}'
union all
select '订单',count(1),'ods_01财务_rpa_有赞商城_订单明细' from rpa.ods_01财务_rpa_有赞商城_订单明细 where `date`  = '${do_date}'
union all
select '订单',count(1),'ods_01财务_rpa_0118财务对账_生意经_订单明细' from rpa.ods_01财务_rpa_0118财务对账_生意经_订单明细 where `date`  = '${do_date}'
union all
select '订单',count(1),'ods_01财务_rpa_0119财务对账_京东旗舰店_订单明细' from rpa.ods_01财务_rpa_0119财务对账_京东旗舰店_订单明细 where query_date = '${do_date}'
union all
select '订单',count(1),'ods_01财务_rpa_0121财务对账_京东自营_订单管理_门店订单' from rpa.ods_01财务_rpa_0121财务对账_京东自营_订单管理_门店订单 where query_date = '${do_date}'
union all
select '账单',count(1),'ods_01财务_rpa_0112财务对账_抖店_资金_资金流水明细' from rpa.ods_01财务_rpa_0112财务对账_抖店_资金_资金流水明细  where  time_of_moving_account like '%${do_date}%'
union all
select '账单',count(1),'ods_01财务_rpa_支付宝_账单明细数据' from rpa.ods_01财务_rpa_支付宝_账单明细数据 where  time_of_occurrence  like '%${do_date}%'
union all
select '账单',count(1),'ods_01财务_rpa_拼多多_对账中心_贷款明细' from rpa.ods_01财务_rpa_拼多多_对账中心_贷款明细 where time_of_occurrence like '%${do_date}%'
union all
select '账单',count(1),'ods_01财务_rpa_0110财务对账_小红书_资金_订单结算明细' from rpa.ods_01财务_rpa_0110财务对账_小红书_资金_订单结算明细 where settlement_time like '%${do_date}%'
union all
select '账单',count(1),'ods_01财务_rpa_0115财务对账_快手小店_资金_结算账单明细' from rpa.ods_01财务_rpa_0115财务对账_快手小店_资金_结算账单明细  where actual_settlement_time like '%${do_date}%'
-- 有赞店铺
union all
select '账单',count(1),'ods_01财务_rpa_018财务对账_有赞_资产_对账单明细' from rpa.ods_01财务_rpa_018财务对账_有赞_资产_对账单明细  where time_of_entry like '%${do_date}%'
-- 有赞储蓄卡
union all
select '账单',count(1),'ods_01财务_rpa_018财务对账_有赞_资产_储值资金用户交易' from rpa.ods_01财务_rpa_018财务对账_有赞_资产_储值资金用户交易  where `time` like '%${do_date}%'
union all
select '账单',count(1),'ods_01财务_rpa_0117财务对账_京东金融_收款管理_已收款账单' from rpa.ods_01财务_rpa_0117财务对账_京东金融_收款管理_已收款账单  where  fee_settlement_time like '%${do_date}%'
union all
select '账单',count(1),'ods_01财务_rpa_0121财务对账_京东自营_结算管理_应收应付对账单' from rpa.ods_01财务_rpa_0121财务对账_京东自营_结算管理_应收应付对账单  where document_date like '%${do_date}%'