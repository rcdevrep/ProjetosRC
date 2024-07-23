user function fa473cta()

_cBanco   := SA6->A6_COD //mv_par01
_cAgencia := SA6->A6_AGENCIA//mv_par03//mv_par02    
_cConta   := SA6->A6_NUMCON//mv_par04//mv_par03    

_aRet     := {_cBanco,_cAgencia,_cConta}


Return(_aRet)
