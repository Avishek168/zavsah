CLASS lsc_ZCDS_I_TRAVEL_AVSAH DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZCDS_I_TRAVEL_AVSAH IMPLEMENTATION.

  METHOD save_modified.

    DATA: lt_log_tab   TYPE STANDARD TABLE OF ztravellog_avsah,
          lt_log_tab_c TYPE STANDARD TABLE OF ztravellog_avsah,
          lt_log_tab_u TYPE STANDARD TABLE OF ztravellog_avsah,
          lt_log_tab_d TYPE STANDARD TABLE OF ztravellog_avsah.

    IF create-travel IS NOT INITIAL.
      lt_log_tab = CORRESPONDING #( create-travel ).

      LOOP AT lt_log_tab ASSIGNING FIELD-SYMBOL(<lfs_log_tab>).
        READ TABLE create-travel ASSIGNING FIELD-SYMBOL(<lfs_travel>) WITH TABLE KEY entity COMPONENTS  TravelId = <lfs_log_tab>-travelid.
        IF sy-subrc EQ 0.

          IF <lfs_travel>-%control-BookingFee EQ cl_abap_behv=>flag_changed.
            <lfs_log_tab>-action = 'Create'.
            <lfs_log_tab>-changedfield = 'BookingFee'.
            <lfs_log_tab>-changedvalue = <lfs_travel>-%data-BookingFee.
            TRY.
                <lfs_log_tab>-id = cl_system_uuid=>create_uuid_x16_static(  ).
              CATCH cx_uuid_error.
            ENDTRY.
            GET TIME STAMP FIELD <lfs_log_tab>-lastchanged.
            <lfs_log_tab>-lastchangedby = cl_abap_context_info=>get_user_technical_name(  ).

            APPEND <lfs_log_tab> TO lt_log_tab_c.
          ENDIF.

          IF <lfs_travel>-%control-OverallStatus EQ cl_abap_behv=>flag_changed.
            <lfs_log_tab>-action = 'Create'.
            <lfs_log_tab>-changedfield = 'OverallStatus'.
            <lfs_log_tab>-changedvalue = <lfs_travel>-%data-OverallStatus.
            TRY.
                <lfs_log_tab>-id = cl_system_uuid=>create_uuid_x16_static(  ).
              CATCH cx_uuid_error.
            ENDTRY.
            GET TIME STAMP FIELD <lfs_log_tab>-lastchanged.
            <lfs_log_tab>-lastchangedby = cl_abap_context_info=>get_user_technical_name(  ).
            APPEND <lfs_log_tab> TO lt_log_tab_c.
          ENDIF.

        ENDIF.
      ENDLOOP.
      INSERT ztravellog_avsah FROM TABLE @lt_log_tab_c.
    ENDIF.

    IF update-travel IS NOT INITIAL.

      lt_log_tab = CORRESPONDING #( update-travel ).

      READ ENTITIES OF zcds_i_travel_avsah IN LOCAL MODE
      ENTITY Travel FROM CORRESPONDING #( update-travel )
      RESULT DATA(lt_travel_id).
      IF lt_travel_id IS NOT INITIAL.
        SELECT
                   travel_id,
                   agency_id
                   FROM ztravel_avsah
                   FOR ALL ENTRIES IN @lt_travel_id
                   WHERE travel_id = @lt_travel_id-TravelId
                   INTO TABLE @DATA(lt_existing_data).
        IF sy-subrc EQ 0.
          SORT lt_existing_data BY travel_id.
        ENDIF.

      ENDIF.


      LOOP AT lt_log_tab ASSIGNING FIELD-SYMBOL(<lfs_log_u>).
        READ TABLE update-travel ASSIGNING FIELD-SYMBOL(<lfs_update_travel>)  WITH TABLE KEY entity COMPONENTS TravelId = <lfs_log_u>-travelid.
        IF sy-subrc EQ 0.

          IF <lfs_update_travel>-%control-AgencyId EQ cl_abap_behv=>flag_changed.
            <lfs_log_u>-action = 'Update'.
            <lfs_log_u>-changedfield = 'Agency_Id'.
            <lfs_log_u>-changedvalue = <lfs_update_travel>-%data-AgencyId.
            TRY.
                <lfs_log_u>-id = cl_system_uuid=>create_uuid_x16_static( ).
              CATCH cx_uuid_error.
            ENDTRY.
            GET TIME STAMP FIELD <lfs_log_u>-lastchanged.
            <lfs_log_u>-previousvalue =  VALUE #( lt_existing_data[ travel_id = <lfs_log_u>-travelid ]-agency_id OPTIONAL ).
            <lfs_log_u>-lastchangedby = cl_abap_context_info=>get_user_technical_name( ).

            APPEND <lfs_log_u> TO lt_log_tab_u.
          ENDIF.

        ENDIF.
      ENDLOOP.

      INSERT ztravellog_avsah FROM TABLE @lt_log_tab_u.

    ENDIF.

    IF delete-travel IS NOT INITIAL.
      lt_log_tab = CORRESPONDING #( delete-travel ).

      LOOP AT lt_log_tab ASSIGNING FIELD-SYMBOL(<lfs_log_d>).
        READ TABLE delete-travel ASSIGNING FIELD-SYMBOL(<lfs_travel_d>) WITH TABLE KEY entity COMPONENTS TravelId = <lfs_log_d>-travelid.
        IF sy-subrc EQ 0.
          <lfs_log_d>-action = 'DELETE'.
          <lfs_log_d>-changedfield = ''.
          <lfs_log_d>-changedvalue = ''.
          TRY.
              <lfs_log_d>-id = cl_system_uuid=>create_uuid_x16_static( ).
            CATCH cx_uuid_error.
          ENDTRY.
          GET TIME STAMP FIELD <lfs_log_d>-lastchanged.
          <lfs_log_d>-lastchangedby = cl_abap_context_info=>get_user_technical_name( ).
          <lfs_log_d>-previousvalue = ''.
          APPEND  <lfs_log_d> TO lt_log_tab_d.
        ENDIF.
      ENDLOOP.

      INSERT ztravellog_avsah FROM TABLE @lt_log_tab_d.

    ENDIF.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
