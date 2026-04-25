CLASS zcl_modify_eml_practice_avsah DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_modify_eml_practice_avsah IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA: it_travel  TYPE TABLE FOR CREATE zcds_i_travel_avsah,
          it_booking TYPE TABLE FOR CREATE zcds_i_travel_avsah\_booking.

*single entity modification(create, create by, delete, update)
*    MODIFY ENTITY zcds_i_travel_avsah
*    CREATE FROM VALUE #(
*                        ( %cid = 'cid1'
*                          %data-CustomerId = '000004'
*                          %data-BeginDate = '20260402'
*                          %control-CustomerId = if_abap_behv=>mk-on
*                          %control-BeginDate = if_abap_behv=>mk-on )
*                       )
*     CREATE BY \_booking
*     FROM VALUE #(
*                   ( %cid_ref = 'cid1'
*                     %target = VALUE #( ( %cid = 'cid11'
*                                        %data = VALUE #( BookingDate = '20260403'
*                                                         CustomerId = '000004'
*                                                         CarrierId = 'UA'
*                                                         ConnectionId = '0059' )
*                                        %control = VALUE #( BookingDate = if_abap_behv=>mk-on
*                                                            customerid = if_abap_behv=>mk-on
*                                                            carrierid = if_abap_behv=>mk-on
*                                                            connectionid = if_abap_behv=>mk-on )
*                                     ) )
*                    )
*                 )
*     MAPPED FINAL(lt_mapped)
*     FAILED FINAL(lt_failed)
*     REPORTED FINAL(lt_result).
*
*    IF lt_failed IS NOT INITIAL.
*      out->write(
*        EXPORTING
*          data   = lt_failed
*      ).
*    ELSE.
*      out->write( lt_result ).
*      COMMIT ENTITIES.
*    ENDIF.


*    MODIFY ENTITY zcds_i_travel_avsah
*    DELETE FROM VALUE #( ( %key-TravelId = |{ '4233' ALPHA = IN }| ) )
*    MAPPED FINAL(lt_mapped_del)
*    FAILED FINAL(lt_failed_del)
*    REPORTED FINAL(lt_result_del).
*    IF lt_failed_del IS NOT INITIAL.
*      out->write( lt_failed_del ).
*    ELSE.
*      COMMIT ENTITIES.
*    ENDIF.

*    MODIFY ENTITY zcds_i_travel_avsah
*    UPDATE FROM VALUE #(
*                         (  %key-TravelId = |{ '4234' ALPHA = IN }|
*                            %data-agencyid = '009870'
*                            %control-AgencyId = if_abap_behv=>mk-on
*                         )
*
*                       )
*    MAPPED FINAL(lt_mapped_upd)
*    REPORTED FINAL(lt_report_upd)
*    FAILED FINAL(lt_failed_upd).
*    IF lt_failed_upd IS NOT INITIAL.
*      out->write( lt_failed_upd ).
*    ELSE.
*      COMMIT ENTITIES.
*    ENDIF.




*Auto fill CID with fields tab
*    MODIFY ENTITY zcds_i_travel_avsah
*    CREATE AUTO FILL CID WITH VALUE #( ( %data = VALUE #( Description = 'AUTO FILL CID'
*                                                          AgencyId = |{ '7008' ALPHA = IN }|
*                                                          BeginDate = '20260404'
*                                                        )
*                                          %control = VALUE #( Description = if_abap_behv=>mk-on
*                                                              agencyid = if_abap_behv=>mk-on
*                                                              begindate = if_abap_behv=>mk-on )
*                                     )
*                                   )
*       MAPPED FINAL(lt_mapped_autocid)
*       REPORTED FINAL(lt_rep_autocid)
*       FAILED FINAL(lt_failed_autocid).
*    IF lt_failed_autocid IS NOT INITIAL.
*      out->write( lt_failed_autocid ).
*    ELSE.
*      COMMIT ENTITIES.
*    ENDIF.



*Multiple entity modification Auto fill CID fields( comp1, comp2 ) with fields tab
*    MODIFY ENTITIES OF zcds_i_travel_avsah
*   ENTITY Booking
*   UPDATE FIELDS ( CustomerId )
*   WITH VALUE #( ( %key-TravelId = |{  '4235' ALPHA = IN }|
*                   %key-BookingId = |{ '10' ALPHA = IN }|
*                   %data-CustomerId = |{ '629' ALPHA = IN }|
*                 )
*               )
*     MAPPED FINAL(lt_mapped_multi)
*     REPORTED FINAL(lt_report_multi)
*     FAILED FINAL(lt_failed_multi).
*
*    COMMIT ENTITIES.


    "auto fill CID set fields with fields_tab"

    MODIFY ENTITIES OF zcds_i_travel_avsah
    ENTITY Travel
    UPDATE SET FIELDS WITH VALUE #(
                                    ( %key-TravelId = |{ '4242' ALPHA = IN }|
                                     AgencyId = '7008'
                                    )
                                  ).
    COMMIT ENTITIES.


  ENDMETHOD.

ENDCLASS.
