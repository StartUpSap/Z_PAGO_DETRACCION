@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help GL ACCOUNT'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_VH_DET_GLACCOUNT
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZOS_D_DETRACTION_GLACCOUNT' )
{
  key value_low as Code,
      text      as Value
}
