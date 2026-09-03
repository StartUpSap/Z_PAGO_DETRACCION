@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Odata Para Pago Detraccion'
@Metadata.ignorePropagatedAnnotations: true
define root view entity Z_DAT_PAG_DETRA
  as select distinct from I_JournalEntryItem        as Item
    inner join            I_JournalEntry            as Head  on  Head.CompanyCode        = Item.CompanyCode
                                                             and Head.FiscalYear         = Item.FiscalYear
                                                             and Head.AccountingDocument = Item.AccountingDocument
    inner join            ZI_VH_DET_GLACCOUNT       as gldet on gldet.Code = Item.GLAccount
  //left outer join ZC_I_DTR_DOCPA    as Itemd on  Itemd.CompanyCode           = Item.CompanyCode
  //and Itemd.FiscalYear            = Item.FiscalYear
  //and Itemd.AccountingDocument    = Item.AccountingDocument
  //and Itemd.SourceLedger          = Item.SourceLedger
  //and Itemd.Ledger                = Item.Ledger
  //and Itemd.LedgerGLLineItem      = Item.LedgerGLLineItem
    left outer join       I_JournalEntryItem        as Itemc on  Head.CompanyCode           = Itemc.CompanyCode
                                                             and Head.FiscalYear            = Itemc.FiscalYear
                                                             and Head.AccountingDocument    = Itemc.AccountingDocument
                                                             and Itemc.FinancialAccountType = 'K'
    left outer join       I_SuplrBankDetailsByIntId as spubn on  Itemc.Supplier              = spubn.Supplier
                                                             //and spubn.BankAccountHolderName = 'DET'
                                                             //and spubn.Bank                  = '00000000018'
                                                             and spubn.Bank like '%018'
    left outer join       I_Withholdingtaxitem      as wtxit on  wtxit.CompanyCode        = Itemc.CompanyCode
                                                             and wtxit.FiscalYear         = Itemc.FiscalYear
                                                             and wtxit.AccountingDocument = Itemc.AccountingDocument
                                                             //and wtxit.WithholdingTaxType = 'DR'
  association [1..1] to I_Supplier                 as _Sup      on  $projection.Supplier = _Sup.Supplier
  association [1..1] to I_Supplier                 as _Supc     on  Itemc.Supplier = _Supc.Supplier
  association [1..*] to I_ExtendedWhldgTaxCodeText as _CodeText on  $projection.WithholdingTaxType = _CodeText.WithholdingTaxType
                                                                and $projection.WithholdingTaxCode = _CodeText.WithholdingTaxCode
                                                                and 'PE'                           = _CodeText.CountryCode
{
  key Item.SourceLedger,
  key Item.Ledger,
  key Item.AccountingDocumentItem,
      @Consumption.valueHelpDefinition: [
           { entity:  { name:    'I_CompanyCodeStdVH',
                        element: 'CompanyCode'  }
           }]
  key Head.CompanyCode,
  key Head.FiscalYear,
  key Head.AccountingDocument,
      Head.FiscalPeriod,
      //Itemd.NumLote,
      Item.AccountingDocumentType,
      //Item.LedgerGLLineItem,
      Head.DocumentDate,
      Head.PostingDate,
      Head.DocumentReferenceID,
      Item.Supplier,
      _Sup.BPSupplierName,
      _Sup.TaxNumber1,
      Item.GLAccount,
      @Consumption.valueHelpDefinition: [
      { entity:  { name:    'I_GLAcctInChtOfAcctsStdVH',
               element: 'GLAccount' }
      }]
      @Consumption.valueHelpDefault.display:true
      @Search.defaultSearchElement: true
      Item.GLAccountType,
      Itemc.Supplier                               as SupplierC, //datos de Supplier
      _Supc.BPSupplierName                         as BPSupplierNameC,
      _Supc.TaxNumber1                             as TaxNumber1C,
      Item.BalanceTransactionCurrency,

      @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
      round( Item.AmountInTransactionCurrency, 0 ) as AmountInTransactionCurrency,
      Item.TransactionCurrency,

      //@Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
      //Item.AmountInBalanceTransacCrcy,
      Head.AbsoluteExchangeRate, //kursf
      spubn.Bank,        //BANKL       Clave Banco         Bank
      spubn.BankAccount, //BANKN       Cuenta Bancaria     BankAccount
      Item.ClearingJournalEntryFiscalYear,
      //Item.ClearingAccountingDocument,
      Item.ClearingJournalEntry,
      Item.ClearingDate,
      wtxit.CompanyCodeCurrency,
      wtxit.DocumentCurrency,
      @DefaultAggregation:#SUM
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      wtxit.WhldgTaxBaseAmtInCoCodeCrcy, //Base Detracc. ML - WT_QSSHH
      @DefaultAggregation:#SUM
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      wtxit.WhldgTaxBaseAmtInTransacCrcy, //Base Detracc. MD - WT_QSSHB
      @DefaultAggregation:#SUM
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      //round(wtxit.WhldgTaxAmtInCoCodeCrcy, 0) as WhldgTaxAmtInCoCodeCrcy,      //Imp. Detracción ML - WT_QBSHH
      wtxit.WhldgTaxAmtInCoCodeCrcy as WhldgTaxAmtInCoCodeCrcy,      //Imp. Detracción ML - WT_QBSHH      
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      Item.AmountInCompanyCodeCurrency as AmountInCompanyCodeCurrency,
      @DefaultAggregation:#SUM
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      wtxit.WhldgTaxAmtInTransacCrcy, //Imp. Detracción MD - WT_QBSHB
      wtxit.WithholdingTaxCode,           //Detracción - WT_WITHCD
      wtxit.WithholdingTaxType,           // CODE    - witht
      _CodeText.WhldgTaxCodeName,
      //I_SuplrBankDetailsByIntId
      //I_PaymentProposalItem
      _Sup,
      _CodeText
}
where
       Head.IsReversal             = ''
        and Head.IsReversed             = ''
  and  Item.ClearingJournalEntry   = ''
  //and  Item.GLAccount              = '0042120090'
  and  Item.SourceLedger           = '0L'
  and  Item.Ledger                 = '0L'
  and(
       Item.AccountingDocumentType = 'KR'
    or Item.AccountingDocumentType = 'KG'
    or Item.AccountingDocumentType = 'KH'
    or Item.AccountingDocumentType = 'RE'
  )
  and  Item.FinancialAccountType   = 'S'
  //and  Item.ReversalReferenceDocument = ''
  and round( Item.AmountInTransactionCurrency, 0 ) <> 0
//and Itemd.NumLote                  is initial
