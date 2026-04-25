@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'travel approver bo'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@UI.headerInfo: {
    typeName: 'Travel',
    typeNamePlural: 'Travels',
    title: {
        type: #STANDARD,
        label: 'Travel',
        criticalityRepresentation: #WITHOUT_ICON,
        value: 'TravelId'
    }
    }
define root view entity zcds_c_travel_approver_avsah
  provider contract transactional_query
  as projection on ZCDS_I_TRAVEL_AVSAH
{
      @UI.facet: [{ position: 10,
                    type: #IDENTIFICATION_REFERENCE,
                    label: 'Travel',
                    id: 'Travel',
                    purpose: #STANDARD
                  },
                  {
                  position: 20,
                    type: #LINEITEM_REFERENCE,
                    label: 'Booking',
                    id: 'Booking',
                    purpose: #STANDARD,
                    targetElement: '_booking'
                  }
                    ]
      @UI.lineItem: [ { position: 10 },
                 {  type: #FOR_ACTION, dataAction: 'copyTravel', label: 'Copy'}]
      @UI.identification: [{ position: 10 }]
      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 5 }]
  key TravelId,
      @ObjectModel.text.element: [ 'AgencyName' ]
      @UI:{ lineItem: [{ position: 20 }],
      selectionField: [{ position: 10 }],
      identification: [{ position: 15 }]
      }
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity: {
                                               name: '/dmo/i_agency',
                                               element: 'AgencyID'
                                           } }]
      AgencyId,
      @UI.hidden: true
      _agency.Name              as AgencyName,
      @ObjectModel.text.element: [ 'CustomerName' ]
      @UI:{ lineItem: [{ position: 30 }],
      selectionField: [{ position: 20 }],
      identification: [{ position: 20 }]
      }
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity: {
                                           name: '/dmo/i_customer',
                                           element: 'CustomerID'
                                       } }]
      CustomerId,
      @UI.hidden: true
      _customer.LastName        as CustomerName,
      @UI.lineItem: [{ position: 40 }]
      @UI.identification: [{ position: 25 }]
      @Search.defaultSearchElement: true
      BeginDate,
      @UI.lineItem: [{ position: 50 }]
      @UI.identification: [{ position: 30 }]
      @Search.defaultSearchElement: true
      EndDate,
      @UI.identification: [{ position: 35 }]
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @UI.lineItem: [{ position: 60 }]
      @UI.identification: [{ position: 40 }]
      @Search.defaultSearchElement: true
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      @Consumption.valueHelpDefinition: [{ entity: {
                                         name: 'i_currency',
                                         element: 'Currency'
                                     } }]
      CurrencyCode,
      @UI.identification: [{ position: 45 }]
      Description,
      @UI:{ lineItem: [{ position: 70 },
                                     {  type: #FOR_ACTION, dataAction: 'acceptTravel', label: 'Accept'},
                                      {  type: #FOR_ACTION, dataAction: 'rejectTravel' , label: 'Reject'}],
      selectionField: [{ position: 30 }],
      identification: [{ position:50 },
                                   {  type: #FOR_ACTION, dataAction: 'acceptTravel', label: 'Accept'},
                                    {  type: #FOR_ACTION, dataAction: 'rejectTravel', label: 'Reject'}],
      textArrangement: #TEXT_ONLY
      }
      @Consumption.valueHelpDefinition: [{ entity: {
                                           name: '/DMO/I_Overall_Status_VH',
                                           element: 'OverallStatus'
                                       } }]
      @ObjectModel.text.element: [ 'OverallstatusText' ]
      OverallStatus,
      @UI.hidden: true
      _overallstatus._Text.Text as OverallstatusText : localized,
      @UI.hidden: true
      CreatedBy,
      @UI.hidden: true
      CreatedAt,
      @UI.hidden: true
      LastChangedBy,
      @UI.hidden: true
      LastChangedAt,
      /* Associations */
      _agency,
      _booking : redirected to composition child zcds_c_Booking_approver_avsah,
      _currency,
      _customer,
      _overallstatus
}
