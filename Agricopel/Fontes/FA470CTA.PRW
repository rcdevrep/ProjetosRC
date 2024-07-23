user function fa470cta()

_cBanco   := mv_par03
//_cAgencia := mv_par09  // Este funcionava na R3 do RPO 8.11
//_cConta   := mv_par10  // Este funcionava na R3 do RPO 8.11
_cAgencia := mv_par15    // Novo parametro devido novas perguntas na R4 do rpo 8.11 V.12
_cConta   := mv_par13    // Novo parametro devido novas perguntas na R4 do rpo 8.11

_aRet     := {_cBanco,_cAgencia,_cConta}


Return(_aRet)
