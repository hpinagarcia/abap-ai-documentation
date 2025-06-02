CLASS zswan_cl_ai_doc_object_proxy DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS get_single_filter_value
      IMPORTING
                iv_name         TYPE string
      RETURNING VALUE(rv_value) TYPE string.

    METHODS set_data
      CHANGING
        ct_data TYPE STANDARD TABLE.

    DATA mo_request      TYPE REF TO if_rap_query_request.
    DATA mo_response     TYPE REF TO if_rap_query_response.
    DATA mo_filter       TYPE REF TO if_rap_query_filter.
    CONSTANTS c_default_limit TYPE i VALUE 100 ##NO_TEXT.
ENDCLASS.


CLASS zswan_cl_ai_doc_object_proxy IMPLEMENTATION.

  METHOD if_rap_query_provider~select.

    mo_request = io_request.
    mo_response = io_response.
    mo_filter = io_request->get_filter( ).

    DATA(lv_package) = CONV devclass( get_single_filter_value( iv_name = 'DEVCLASS' ) ).

    IF lv_package IS INITIAL.
    "RAISE EXCEPTION TYPE zswan_cx_rap_ai_doc
    "   MESSAGE ID 'ZSWAN_AI_DOC' NUMBER 000.
      RAISE EXCEPTION TYPE zswan_cx_rap_ai_doc
        EXPORTING
          iv_msgno = '000'.
    ENDIF.

    IF zswan_cl_ai_doc=>exists_package( lv_package ) EQ abap_false.
      RAISE EXCEPTION TYPE zswan_cx_rap_ai_doc
        EXPORTING
          iv_msgno = '001'
          iv_attr1 = CONV #( lv_package ).
    ENDIF.

    DATA(lt_objects) = zswan_cl_ai_doc=>get_all_package_contents( iv_package = lv_package ).

    set_data( CHANGING ct_data = lt_objects ).

  ENDMETHOD.

  METHOD get_single_filter_value.

    TRY.
        DATA(lt_filters) = mo_filter->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range.
        "handle exception
    ENDTRY.

    DATA(lv_filter_key) = to_upper( iv_name ).

    CLEAR rv_value.

    LOOP AT lt_filters ASSIGNING FIELD-SYMBOL(<fs_filter>).
      <fs_filter>-name = to_upper( <fs_filter>-name ).
    ENDLOOP.

    IF line_exists( lt_filters[ name = lv_filter_key ] ).
      DATA(ls_line) = lt_filters[ name = lv_filter_key ].
      DATA(ls_range) = ls_line-range[ 1 ].

      rv_value = ls_range-low.
    ENDIF.

  ENDMETHOD.

  METHOD set_data.

    IF lines( ct_data ) EQ 0.
      mo_response->set_total_number_of_records( 0 ).
      mo_response->set_data( VALUE string_table( ) ).
      RETURN.
    ENDIF.

    DATA(lt_sort) = VALUE abap_sortorder_tab(
                                 FOR sort_element IN mo_request->get_sort_elements( )
                                 ( name = sort_element-element_name descending = sort_element-descending ) ).

    IF lt_sort IS NOT INITIAL.
      SORT ct_data BY (lt_sort).
    ENDIF.

    DATA(lv_top) = mo_request->get_paging( )->get_page_size( ).

    IF lv_top < 0.
      lv_top = c_default_limit.
    ENDIF.

    DATA(lv_skip) = mo_request->get_paging( )->get_offset( ).

    IF lv_top IS NOT INITIAL OR lv_skip IS NOT INITIAL.
      /iwbep/cl_mgw_data_util=>paging( EXPORTING is_paging = VALUE #( top  = lv_top
                                                                      skip = lv_skip )
                                       CHANGING  ct_data   = ct_data ).
    ENDIF.

    IF mo_request->is_total_numb_of_rec_requested( ).
      mo_response->set_total_number_of_records( lines( ct_data ) ).
    ENDIF.

    mo_response->set_data( ct_data ).

  ENDMETHOD.

ENDCLASS.
