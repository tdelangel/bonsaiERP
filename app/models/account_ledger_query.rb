class AccountLedgerQuery
  def initialize(rel = AccountLedger.scoped)
    @rel = rel
  end

  def money(id)
    @rel.where{(account_id.eq id) | (account_to_id.eq id)}.order('date desc')
    .includes({account: :contact}, :account_to, :approver, :creator)
  end

  def money_paged(id, page)
    money.page(page)
  end

  def payments(account_id)
    @rel.select(payment_columns(account_id).join(", "))
    .where("account_id=:id OR account_to_id=:id", id: account_id)
    .includes(:account, :account_to)
  end

  def payments_ordered(account_id)
    payments(account_id).order('date desc, id desc')
  end

private
  def payment_columns(account_id)
    AccountLedger.column_names + ["account_id=#{account_id} AS is_account"]
  end
end
