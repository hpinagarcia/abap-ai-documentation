@EndUserText.label: 'Custom Entity for development objects'
@ObjectModel: {
    query: {
        implementedBy: 'ABAP:ZSWAN_CL_AI_DOC_OBJECT_PROXY'
    }
}
define custom entity ZSWAN_CE_AI_DOC_OBJECT
{
  key pgmid       : pgmid;
  key object      : trobjtype;
  key obj_name    : sobj_name;
      devclass    : devclass;
      description : abap.string(0);
}
