#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 06/11/01

User Function AGR154()        // incluido pelo assistente de conversao do AP5 IDE em 06/11/01

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Declaracao de variaveis utilizadas no programa atraves da funcao    Ё
//Ё SetPrvt, que criara somente as variaveis definidas pelo usuario,    Ё
//Ё identificando as variaveis publicas do sistema utilizadas no codigo Ё
//Ё Incluido pelo assistente de conversao do AP5 IDE                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

SetPrvt("NOPCX,NUSADO,AHEADER,ACOLS,_NPOSFOR,_NPOSGRU")
SetPrvt("_NPOSCOMP,_NPOSLARG,_NPOSQTDE,_NPOSFP,_NPOSENT,_NPOSDEL")
SetPrvt("CTIPOENT,DDATA,NLINGETD,CTITULO,AC,AR")
SetPrvt("ACGD,CLINHAOK,CTUDOOK,LRETMOD2,NIT,xTotCheque,cTotCheque,cMens")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Opcao de acesso para o Modelo 2                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
// 3,4 Permitem alterar getdados e incluir linhas
// 6 So permite alterar getdados e nao incluir linhas
// Qualquer outro numero so visualiza
nOpcx := 3
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Montando aHeader                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SEF->(DbSetOrder(1))               // filial+Banco+Agencia+Conta+Num
dbSelectArea("Sx3")
dbSetOrder(1)
dbSeek("SEF")
nUsado  := 0
aHeader := {}
While !Eof() .And. (x3_arquivo == "SEF")
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
           If Upper(AllTrim(X3_CAMPO)) == "EF_VALORBX" 
              dbSkip()
              Loop
           Endif
           If Upper(AllTrim(X3_CAMPO)) <> "EF_PREFIXO" .AND.;
              Upper(AllTrim(X3_CAMPO)) <> "EF_TIPO"    .AND.;
              Upper(AllTrim(X3_CAMPO)) <> "EF_BANCO"   .AND.;
              Upper(AllTrim(X3_CAMPO)) <> "EF_AGENCIA" .AND.;
              Upper(AllTrim(X3_CAMPO)) <> "EF_CONTA"   .AND.;
              Upper(AllTrim(X3_CAMPO)) <> "EF_NUM"     .AND.;
              Upper(AllTrim(X3_CAMPO)) <> "EF_VENCTO"  .AND.;
              Upper(AllTrim(X3_CAMPO)) <> "EF_VALOR"   .AND.;
              Upper(AllTrim(X3_CAMPO)) <> "EF_CMC7"    
              dbSkip()
              Loop
           Endif
           nUsado := nUsado + 1
           AADD(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
                x3_tamanho, x3_decimal,"",;
                x3_usado, x3_tipo, x3_arquivo, x3_context } )
    Endif
    dbSkip()
End
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Montando aCols                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aCols  := Array(1,nUsado+1)    
dbSelectArea("Sx3")
dbSeek("SEF")
nUsado := 0
While !Eof() .And. (x3_arquivo == "SEF")
           If Upper(AllTrim(X3_CAMPO)) == "EF_VALORBX" 
              dbSkip()
              Loop
           Endif
           If Upper(AllTrim(X3_CAMPO)) <> "EF_PREFIXO" .AND.;
              Upper(AllTrim(X3_CAMPO)) <> "EF_TIPO"    .AND.;
              Upper(AllTrim(X3_CAMPO)) <> "EF_BANCO"   .AND.;
              Upper(AllTrim(X3_CAMPO)) <> "EF_AGENCIA" .AND.;
              Upper(AllTrim(X3_CAMPO)) <> "EF_CONTA"   .AND.;
              Upper(AllTrim(X3_CAMPO)) <> "EF_NUM"     .AND.;
              Upper(AllTrim(X3_CAMPO)) <> "EF_VENCTO"  .AND.;
              Upper(AllTrim(X3_CAMPO)) <> "EF_VALOR"   .AND.;
              Upper(AllTrim(X3_CAMPO)) <> "EF_CMC7"    
              dbSkip()
              Loop
           Endif
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
           nUsado := nUsado + 1  
           IF nOpcx == 3
              IF x3_tipo == "C"
                 aCOLS[1][nUsado] := SPACE(x3_tamanho)
              Elseif x3_tipo == "N"
                 aCOLS[1][nUsado] := 0
              Elseif x3_tipo == "D"
                 aCOLS[1][nUsado] := CTOD('  /  /  ')
              Elseif x3_tipo == "M"
                 aCOLS[1][nUsado] := ""
              Else
                 aCOLS[1][nUsado] := .F.
              Endif
           Endif
        Endif
   dbSkip()
End

aCOLS[1][nUsado+1] := .F. 

_nPosPref := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_PREFIXO" })
_nPosTipo := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_TIPO"    })
_nPosBanc := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_BANCO"   })
_nPosAgen := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_AGENCIA" })
_nPosCont := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_CONTA"   })
_nPosNum  := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_NUM"     })
_nPosVenc := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_VENCTO"  })
_nPosValo := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_VALOR"   })
_nPosCMC7 := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_CMC7"    })

_nPosDel  := Len(aHeader) + 1

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis do Cabecalho do Modelo 2                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dData    := ddatabase
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis do Rodape do Modelo 2                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nLinGetD := 0
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Titulo da Janela                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cTitulo := "Cheques Extras"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Array com descricao dos campos do Cabecalho do Modelo 2      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aC := {}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
#IFDEF WINDOWS
//        AADD(aC,{"cTipoent"        ,{15,10} ,"Tipo" ,"@!",,,})
        AADD(aC,{"dData"        ,{15,200} ,"Data",    ,,,})
#ELSE
//        AADD(aC,{"cTipoent"     ,{6,5} ,"Tipo"       ,"@!"                   ,,,})
        AADD(aC,{"dData"     ,{6,40} ,"Data"      ,   ,,,})
#ENDIF
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Array com descricao dos campos do Rodape do Modelo 2         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aR := {}
// aR[n,1] = Nome da Variavel Ex.:"cCliente"
// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aR[n,3] = Titulo do Campo
// aR[n,4] = Picture
// aR[n,5] = Validacao
// aR[n,6] = F3
// aR[n,7] = Se campo e' editavel .t. se nao .f.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Array com coordenadas da GetDados no modelo2                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
#IFDEF WINDOWS
        aCGD := {42,5,123,315}
#ELSE
        aCGD := {08,04,20,73}
#ENDIF
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Validacoes na GetDados da Modelo 2                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//cLinhaOk := "ExecBlock('Md2LinOk',.f.,.f.)"
//cTudoOk  := "ExecBlock('Md2TudOk',.f.,.f.)"
cLinhaOk := "AllwaysTrue()" 
cTudoOk  := "AllwaysTrue()"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chamada da Modelo2                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
// lRetMod2 = .t. se confirmou 
// lRetMod2 = .f. se cancelou

ExecBlock('AGR155',.f.,.f.)

lRetMod2   := .t.

xTotCheque := 0
cTotCheque := ""

// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
// objeto Getdados Corrente

While lRetMod2

   lRetMod2 := Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk)

   If lRetMod2
   
      SEF->(DbSetOrder(1))               // filial+BANCO+AGENCIA+CONTA+NUM
      For nIt := 1 To Len(aCols)

         If !aCols[nIt,_nPosDel]

            DbSelectArea("SEF")
	         DbSetOrder(1)
		      DbSeek(xFilial("SEF")+aCols[nIt,_nPosBanc]+aCols[nIt,_nPosAgen]+aCols[nIt,_nPosCont]+aCols[nIt,_nPosNum])
		      While !Eof()
		         If SEF->EF_VENCTO == aCols[nIt,_nPosVenc]
                  MsgStop('Cheque Ja Cadastrado...'+aCols[nIt,_nPosNum]) 
                  lRetMod2 := .f.
               Endif
               Dbskip()
            End
            
            xTotCheque := xTotCheque + aCols[nIt,_nPosValo]

         Endif

      Next nIt  
      
      If !lRetMod2
         lRetMod2 := .t.
         loop
      Endif
      
      IF !MsgYesNo("Confirma Atualizacao deste lote ? "+Str(xTotcheque))
      	xTotCheque := 0
         lRetMod2   := .t.
         loop
      Endif
   
   Endif
   

   If lRetMod2 
   
    

      SEF->(DbSetOrder(1))               // filial+BANCO+AGENCIA+CONTA+NUM
      For nIt := 1 To Len(aCols)

         If !aCols[nIt,_nPosDel]

            RecLock("SEF",.T.)
            SEF->EF_FILIAL  := xFilial()
            SEF->EF_PREFIXO := aCols[nIt,_nPosPref]
            SEF->EF_TIPO    := aCols[nIt,_nPosTipo]
            SEF->EF_BANCO   := aCols[nIt,_nPosBanc]
            SEF->EF_AGENCIA := aCols[nIt,_nPosAgen]
            SEF->EF_CONTA   := aCols[nIt,_nPosCont]
            SEF->EF_NUM     := aCols[nIt,_nPosNum]
            SEF->EF_VENCTO  := aCols[nIt,_nPosVenc]
            SEF->EF_VALOR   := aCols[nIt,_nPosValo]
            SEF->EF_CMC7    := aCols[nIt,_nPosCmc7]
            SEF->EF_DATA    := dDataBase
            SEF->EF_HIST    := 'CHEQUE EXTRA'
            SEF->EF_ORIGEM  := 'AGR154'
            MsUnLock("SEF")

         Endif
      Next nIt

      Return

   EndIF

   If !lRetMod2
	
	   #IFDEF WINDOWS
		   MsgStop("Voce abortou a operacao!")
	   #ELSE
	      Alert("Voce abortou a operacao!")
	   #ENDIF
	
	   Return
	
   Endif

End

Return