@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Reporte Detraccion'
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
define view entity Z_REPO_DETRAC 
as select from I_JournalEntry as JE
    inner join I_JournalEntryItem as JEI
      on  JE.AccountingDocument = JEI.AccountingDocument
      and JE.CompanyCode        = JEI.CompanyCode
      and JE.FiscalYear         = JEI.FiscalYear
      
    left outer join I_JournalEntryItem as JEI_2
      on  JEI_2.AccountingDocument = JEI.AccountingDocument
      and  JEI_2.LedgerGLLineItem = '000001'
      and JEI_2.CompanyCode        = JEI.CompanyCode
      and JEI_2.FiscalYear         = JEI.FiscalYear

    left outer join I_Withholdingtaxitem as WHT
      on  JE.AccountingDocument = WHT.AccountingDocument
      and JE.CompanyCode        = WHT.CompanyCode
      and JE.FiscalYear         = WHT.FiscalYear

    left outer join I_BusinessPartner as BP
      on JEI_2.Supplier = BP.BusinessPartner
      
      left outer join I_JournalEntryItem as JEI_3
      on  JEI_3.AccountingDocument = JEI.AccountingDocument
      and JEI_3.CompanyCode        = JEI.CompanyCode
      and JEI_3.ClearingJournalEntryFiscalYear         = JEI.FiscalYear
      
    left outer join I_Supplier as SP
      on JEI_2.Supplier = SP.Supplier
{
  key JE.AccountingDocument              as AccountingDocument,
  key JE.CompanyCode                     as CompanyCode,
  key JE.FiscalYear                      as FiscalYear,

      JE.DocumentReferenceID             as DocumentReferenceID,
      JE.FiscalPeriod                    as FiscalPeriod,
      JE.DocumentDate                    as DocumentDate,
      JE.PostingDate                     as PostingDate,

      JEI_2.Supplier                       as Supplier,
      BP.BusinessPartnerFullName         as BusinessPartnerFullName,
      JEI.GLAccount                      as GLAccount,

      WHT.WithholdingTaxCode             as WithholdingTaxCode,

      //@Semantics.currencyCode: true
      JE.TransactionCurrency             as TransactionCurrency,
      
      JE.CompanyCodeCurrency             as CompanyCodeCurrency ,
            
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      WHT.WhldgTaxBaseAmtInTransacCrcy   as BaseImponibleMonDoc,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      WHT.WhldgTaxAmtInTransacCrcy       as ImporteDetraccionMonDoc,

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      WHT.WhldgTaxBaseAmtInCoCodeCrcy    as BaseImponibleMonSoc,
      
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      WHT.WhldgTaxAmtInCoCodeCrcy        as ImporteDetraccionMonSoc,
      
      @Semantics.amount.currencyCode: 'TransactionCurrency'      
      WHT.WhldgTaxBaseAmtInAddlCrcy2     as BaseImponibleMonFuerte,
      
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      WHT.WhldgTaxAmtInAddlCrcy2         as ImporteDetraccionMonFuerte,

      JEI_3.ClearingAccountingDocument     as ClearingAccountingDocument,

      //JEI.BusinessPartnerReferenceKey1   as NroConstancia,
      //JEI.BusinessPartnerReferenceKey2   as FechaConstancia,
      
      SP.TaxNumber1 as RUC,
      

      case
        when JEI_3.ClearingAccountingDocument <> ''
          then 'Pagado'
        else 'Pendiente'
      end                                as Estado
}

where
    ( JE.AccountingDocumentType = 'RE'
      or JE.AccountingDocumentType = 'KR'
      or JE.AccountingDocumentType = 'KG' )
  and
    ( JE.DocumentReferenceID like '01%'
      or JE.DocumentReferenceID like '07%'
      or JE.DocumentReferenceID like '08%' )
  and
  ( JEI.GLAccount = '0042120090'
      or JEI.GLAccount = '0043120090'
      )     
