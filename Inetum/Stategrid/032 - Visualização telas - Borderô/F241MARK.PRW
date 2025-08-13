/* 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Programa  ³F241MARK  ºAutor  ³ Jader Berto         Data ³ 20/05/2024      º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºDesc.  ³F241MARK altera as posições dos campos de tela MarkBrowse      º±±
±±º                                                                       º±±
±±º                                                                       º±±
±±º                                                                       º±±
±±º                                                            	          º±±
±±º                                                                       º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºUso    ³ FINA240                                                       º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
*/   
User Function F241MARK()
Local aArea := GetArea()
Local aRet := {} 
Local nX
Local cCampo
Local cTitulo
Local cPicture
Local cCampos := SuperGetMV("FS_CMPBOR", .F., "E2_FILIAL|E2_NUM|E2_NOMFOR|E2_VENCREA|E2_DATAAGE|E2_VALOR|E2_XVLIQ|E2_FORBCO|E2_FORAGE|E2_FAGEDV|E2_FORCTA|E2_FCTADV|E2_LINDIG|E2_XMULTA|E2_XDESC|E2_XJUR|E2_COFINS|E2_PIS|E2_CSLL|E2_INSS|E2_ISS|E2_IRRF|E2_ACRESC|E2_DECRESC")
Local aCampos

    aCampos   := Separa(cCampos, '|', .T.)

    AADD(aRet,{"E2_OK",""," ",""})

    For nX := 1 To Len( aCampos )

        cCampo  := aCampos[nX]

        cTitulo := GetSX3Cache(cCampo, "X3_TITULO")
        cPicture:= PesqPict( 'SE2', cCampo )

        AADD(aRet,{cCampo,"",AllTrim(cTitulo),cPicture})


    Next nX


RestArea(aArea)

Return aRet
