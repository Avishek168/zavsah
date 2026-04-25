CLASS zcl_read_practice_avsah DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_read_practice_avsah IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

*short method of read entity includes control component and from value along with key field
*    READ ENTITY zcds_i_travel_avsah
*    FROM VALUE #( (  %key-TravelId = ' 00008514' )
*                                 ( %control-AgencyId = if_abap_behv=>mk-on )
*                                  ( %control-CustomerId = if_abap_behv=>mk-on )
*                                  ( %control-BeginDate = if_abap_behv=>mk-on )
*                                )
*    RESULT DATA(lt_result_short)
*    FAILED DATA(lt_failed_short).
*    out->write(
*      EXPORTING
*        data   = lt_result_short
*    ).

*short method of read entity includes specific field with value along with key field
*    READ ENTITY zcds_i_travel_avsah
*    FIELDS (  AgencyId CustomerId BeginDate BookingFee )
*    WITH VALUE #(  (  %key-TravelId = '00008514' )  )
*    RESULT DATA(lt_result_short)
*    FAILED DATA(lt_failed_short).
*    out->write(
*      EXPORTING
*        data   = lt_result_short
*    ).

*short method of read entity to read all the fields along with key field
*    READ ENTITY zcds_i_travel_avsah
*    ALL FIELDS
*    WITH VALUE #(  (  %key-TravelId = '00008514' )  )
*    RESULT DATA(lt_result_short)
*    FAILED DATA(lt_failed_short).
*    out->write(
*      EXPORTING
*        data   = lt_result_short
*    ).


*short method of read entity by association along with key field
*    READ ENTITY zcds_i_travel_avsah
*    BY \_booking
*    ALL FIELDS WITH VALUE #( ( %key-TravelId = '00008514' ) )
*    RESULT DATA(lt_result_short)
*    FAILED DATA(lt_failed_short).
*
*    out->write( lt_result_short ).

*longer format where we can read multiple entity
*    READ ENTITIES OF zcds_i_travel_avsah
*
*    ENTITY Travel ALL FIELDS WITH VALUE #( ( %key-TravelId = '00004136'  ) )
*    RESULT DATA(lt_result_travel)
*
*    ENTITY Booking ALL FIELDS WITH VALUE #( ( %key-TravelId = '00004136'
*                                                                                       %key-BookingId = '0001'  ) )
*                                                             RESULT DATA(lt_result_booking)
*
*                                                             FAILED DATA(lt_failed_data).
*
*
*    IF   lt_failed_data IS NOT INITIAL.
*      out->write( 'Read Failed' ).
*    ELSE.
*      out->write( lt_result_travel ).
*      out->write(  lt_result_booking ).
*    ENDIF.



*Dynamic format read operation to read multiple entity

    DATA:
      it_travel_dy      TYPE TABLE FOR READ IMPORT zcds_i_travel_avsah,
      it_booking_dy     TYPE TABLE FOR READ IMPORT zcds_i_booking_avsah,
      it_op_tab         TYPE abp_behv_retrievals_tab,
      it_travel_result  TYPE TABLE FOR READ RESULT zcds_i_travel_avsah,
      it_booking_RESULT TYPE TABLE FOR READ RESULT zcds_i_booking_avsah,
      it_failed_data type table for FAILED zcds_i_travel_avsah.


    "first need to select key fields and output fields for both the entity
*    it_travel_dy = VALUE #( (   %key-TravelId = '00004136'
*                                             %control = VALUE #( AgencyId = if_abap_behv=>mk-on
*                                                                                 CustomerId = if_abap_behv=>mk-on
*                                                                                 BeginDate = if_abap_behv=>mk-on )
*                                           ) ).
*
*    it_booking_dy = VALUE #(
*                                                  (  %key-TravelId = '00004136'
*                                                     %control = VALUE #( BookingId = if_abap_behv=>mk-on
*                                                                                       BookingDate = if_abap_behv=>mk-on
*                                                                                       BookingStatus = if_abap_behv=>mk-on )
*                                                   )
*                                               ).

*    it_op_tab = VALUE #(
*                                        ( op = if_abap_behv=>op-r-read
*                                           entity_name = 'ZCDS_I_TRAVEL_AVSAH'
*                                           instances = REF #( it_travel_dy )
*                                           results = REF #( it_travel_result )
*                                         )
*                                             (  op = if_abap_behv=>op-r-read_ba
*                                                sub_name = '_BOOKING'
*                                                entity_name = 'ZCDS_I_TRAVEL_AVSAH'
*                                                instances = REF #( it_booking_dy )
*                                                results = REF #( it_booking_RESULT )
*                                         )
*                                       ).
*
*
*   READ ENTITIES
*    OPERATIONS IT_OP_TAB
*   FAILED data(lt_failed_dy) .
*
*   if lt_failed_dy is initial.
*     out->write( it_travel_result ).
*     out->write( it_booking_result ).
*   endif.

  ENDMETHOD.
ENDCLASS.
