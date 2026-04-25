CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_cba_Booksup FOR NUMBERING
      IMPORTING entities FOR CREATE Booking\_Booksup.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Booking RESULT result.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR booking~calculatetotalprice.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD earlynumbering_cba_Booksup.

    DATA: lv_max_suppid TYPE /dmo/booking_supplement_id.

    READ ENTITIES OF zcds_i_travel_avsah
    IN LOCAL MODE
    ENTITY Booking BY \_booksup
    FROM CORRESPONDING #( entities )
    LINK DATA(lt_link_data).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_group_entities>) GROUP BY <lfs_group_entities>-%tky.
*check already any booking supplement id exists or not then assign it to lv_max_suppid else its blank
      lv_max_suppid = REDUCE #( INIT lv_max TYPE /dmo/booking_supplement_id
                                FOR ls_link_data IN lt_link_data USING KEY entity
                                 WHERE ( source-%tky = <lfs_group_entities>-%tky )
                                 NEXT lv_max = COND #( WHEN lv_max LT ls_link_data-target-BookingSupplementId
                                                       THEN ls_link_data-target-BookingSupplementId
                                                       ELSE lv_max )
                              ).

*in case of draft functionality is enabled, else can be ignored

      lv_max_suppid = REDUCE #( INIT lv_max = lv_max_suppid
                                FOR ls_entities IN entities USING KEY entity
                                WHERE ( %tky = <lfs_group_entities>-%tky )
                                FOR ls_booksup IN ls_entities-%target
                                NEXT lv_max = COND #( WHEN lv_max LT ls_booksup-BookingSupplementId THEN
                                                       ls_booksup-BookingSupplementId
                                                       ELSE lv_max )
                              ).

*loop through the particular travel and booking id through %tky
      LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entities>)
                               USING KEY entity
                               WHERE %tky EQ <lfs_group_entities>-%tky.

        LOOP AT <lfs_entities>-%target ASSIGNING FIELD-SYMBOL(<lfs_target>).
          APPEND CORRESPONDING #( <lfs_target> ) TO mapped-booksupp ASSIGNING FIELD-SYMBOL(<lfs_booksupp>).
*check if the booking supplement id is initial, then increase the lv_max_suppid by 10 and assign
          IF <lfs_target>-BookingSupplementId IS INITIAL.
            lv_max_suppid += 10.
            <lfs_booksupp>-BookingSupplementId = lv_max_suppid.
          ENDIF.

        ENDLOOP.

      ENDLOOP.

    ENDLOOP.


  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zcds_i_travel_avsah IN LOCAL MODE
    ENTITY Travel BY \_booking
    FIELDS ( TravelId BookingId BookingStatus )
    WITH CORRESPONDING #(  keys )
     RESULT DATA(lt_result).

    result = VALUE #(  FOR ls_result IN lt_result
                                    (
                                      %tky = ls_result-%tky
                                      %features-%assoc-_booksup = COND #(  WHEN ls_result-BookingStatus EQ 'X' THEN if_abap_behv=>fc-o-disabled
                                                                                                                ELSE  if_abap_behv=>fc-o-enabled  )
                                    )
                                  ).


  ENDMETHOD.

  METHOD calculateTotalPrice.

    DATA: lt_travelids TYPE STANDARD TABLE OF  zcds_i_travel_avsah WITH UNIQUE HASHED KEY key COMPONENTS TravelId.
    lt_travelids = CORRESPONDING #( keys DISCARDING DUPLICATES MAPPING TravelId = TravelId ).

    MODIFY ENTITIES OF zcds_i_travel_avsah IN LOCAL MODE
    ENTITY Travel EXECUTE reCalTotalPrice
    FROM CORRESPONDING #( lt_travelids ).


  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
