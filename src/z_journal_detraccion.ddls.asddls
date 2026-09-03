@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Odata para Journal'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z_JOURNAL_DETRACCION as select from I_JournalEntryItem
{
    key CompanyCode,
    key AccountingDocument,
    GLAccount,
    //ClearingAccountingDocument
    ClearingJournalEntry as ClearingAccountingDocument
    }
    where
    //GLAccount = '0042120090' and
    SourceLedger = '0L'
    
