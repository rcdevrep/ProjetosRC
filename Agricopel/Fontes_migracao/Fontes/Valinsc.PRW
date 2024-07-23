#include "rwmake.ch"     

User Function Valinsc() 


SetPrvt("_LRET,CISENTO,CESTADO,CINSCR,CDIGORI,CCODEST")
SetPrvt("NNUMA,NNUMB,NNUMC,NNUMD,NNUME,NNUMF")
SetPrvt("NNUMG,NNUMH,NTOTAL,NRESTO,CDIGIT,NVALP")
SetPrvt("NVALD,NSUBTR,CDIGORI2,CDIGORI1,CDIGIT1,NNUMAA")
SetPrvt("NNUMBA,NNUMCA,NNUMDA,NNUMEA,NNUMFA,NNUMGA")
SetPrvt("NTOTALA,NRESTOA,CDIGIT2,NNUMI,NNUMJ,NNUMK")
SetPrvt("NNUMHA,NNUMIA,NNUMJA,NNUMKA,NNUMLA,NSUBTRA")
SetPrvt("CINSCRESP,CINSCRT,CSUBSB,NNUMBB,CSUBSF,NNUMFF")
SetPrvt("CSUBSH,NNUMHH,CSUBSJ,NNUMJJ,CSUBSL,NNUML")
SetPrvt("NNUMLL,NNUMM,")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ VERDVA2  ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastro de Clientes - SA2                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

_lRet := .T.

cIsento := rtrim(M->A2_INSCR)
If cIsento == "ISENTO"
	Return(_lRet)       
Else
	ESTADO()
Endif

Return(_lRet)    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ESTADO   ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica o Estado informado                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ESTADO()

cEstado := M->A2_EST

Do Case
	Case cEstado == "AC"
		DVAC()
	Case cEstado == "AL"
		DVAL()
	Case cEstado == "AM"
		DVAM()
	Case cEstado == "AP"
		DVAP()
	Case cEstado == "BA"
		DVBA()
	Case cEstado == "CE"
		DVCE()
	Case cEstado == "DF"
		DVDF()
	Case cEstado == "ES"
		DVES()
	Case cEstado == "GO"
		DVGO()
	Case cEstado == "MA"
		DVMA()
	Case cEstado == "MG"
		DVMG()
	Case cEstado == "MS"
		DVMS()
	Case cEstado == "MT"
		DVMT()
	Case cEstado == "PA"
		DVPA()
	Case cEstado == "PB"
		DVPB()
	Case cEstado == "PE"
		DVPE()
	Case cEstado == "PI"
		DVPI()
	Case cEstado == "PR"
		DVPR()
	Case cEstado == "RJ"
		DVRJ()
	Case cEstado == "RN"
		DVRN()
	Case cEstado == "RO"
		DVRO()
	Case cEstado == "RR"
		DVRR()
	Case cEstado == "RS"
		DVRS()
	Case cEstado == "SC"
		DVSC()
	Case cEstado == "SE"
		DVSE()
	Case cEstado == "SP"
		DVSP()
	Case cEstado == "TO"
		DVTO()
	Otherwise
		ALERTA2()
EndCase

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVAC     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ do Acre                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVAC()

If len(alltrim(M->A2_INSCR)) <> 9 .OR. alltrim(M->A2_INSCR) == "000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO000" .OR. alltrim(M->A2_INSCR) == "ISENTA000"
	ALERTA3()
Endif

cInscr  := subs(alltrim(M->A2_INSCR),01,8)
cDigOri := subs(alltrim(M->A2_INSCR),09,1)

cCodEst := subs(cInscr,01,2)

If cCodEst <> "01"
	ALERTA3()
Endif

nNumA := val(subs(cInscr,08,1))*2
nNumB := val(subs(cInscr,07,1))*3
nNumC := val(subs(cInscr,06,1))*4
nNumD := val(subs(cInscr,05,1))*5
nNumE := val(subs(cInscr,04,1))*6
nNumF := val(subs(cInscr,03,1))*7
nNumG := val(subs(cInscr,02,1))*8
nNumH := val(subs(cInscr,01,1))*9

nTotal := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH
nResto := mod(nTotal,11)

If nResto < 2
	cDigit := "0"
Else
	cDigit := alltrim((str(int(11-nResto))))
Endif

If cDigit <> cDigOri
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVAL     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ do Alagoas                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVAL()

If len(alltrim(M->A2_INSCR)) <> 9 .OR. alltrim(M->A2_INSCR) == "000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO000" .OR. alltrim(M->A2_INSCR) == "ISENTA000"
	ALERTA()
Endif

cInscr  := subs(alltrim(M->A2_INSCR),01,8)
cDigOri := subs(alltrim(M->A2_INSCR),09,1)

cCodEst := subs(cInscr,01,2)

If cCodEst <> "24"
	ALERTA()
Endif

nNumA := val(subs(cInscr,08,1))*2
nNumB := val(subs(cInscr,07,1))*3
nNumC := val(subs(cInscr,06,1))*4
nNumD := val(subs(cInscr,05,1))*5
nNumE := val(subs(cInscr,04,1))*6
nNumF := val(subs(cInscr,03,1))*7
nNumG := val(subs(cInscr,02,1))*8
nNumH := val(subs(cInscr,01,1))*9

nTotal := (nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH)*10
nResto := nTotal-((int(nTotal/11))*11)

If nResto == 10
	cDigit := "0"
Else
	cDigit := alltrim((str(int(nResto))))
Endif

If cDigit <> cDigOri
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVAM     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ do Amazonas                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVAM()

If len(alltrim(M->A2_INSCR)) <> 9 .OR. alltrim(M->A2_INSCR) == "000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO000" .OR. alltrim(M->A2_INSCR) == "ISENTA000"
	ALERTA()
Endif

cInscr  := subs(alltrim(M->A2_INSCR),01,8)
cDigOri := subs(alltrim(M->A2_INSCR),09,1)

nNumA := val(subs(cInscr,08,1))*2
nNumB := val(subs(cInscr,07,1))*3
nNumC := val(subs(cInscr,06,1))*4
nNumD := val(subs(cInscr,05,1))*5
nNumE := val(subs(cInscr,04,1))*6
nNumF := val(subs(cInscr,03,1))*7
nNumG := val(subs(cInscr,02,1))*8
nNumH := val(subs(cInscr,01,1))*9

nTotal := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH

If nTotal < 11
	cDigit := alltrim((str(int(11-nTotal))))
Else
	nResto := mod(nTotal,11)
	If nResto < 2
		cDigit := "0"
	Else
		cDigit := alltrim((str(int(11-nResto))))
	Endif
Endif

If cDigit <> cDigOri
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVAP     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ do Amapa                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVAP()

If len(alltrim(M->A2_INSCR)) <> 9 .OR. alltrim(M->A2_INSCR) == "000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO000" .OR. alltrim(M->A2_INSCR) == "ISENTA000"
	ALERTA()
Endif

cInscr  := subs(alltrim(M->A2_INSCR),01,8)
cDigOri := subs(alltrim(M->A2_INSCR),09,1)

cCodEst := subs(cInscr,01,2)

If cCodEst <> "03"
	ALERTA2()
Endif

nValP   := 0
nValD   := 0

Do Case
	Case cInscr >= "03000001" .AND. cInscr <= "03017000"
		nValP := 5
		nValD := 0
	Case cInscr >= "03017001" .AND. cInscr <= "03019022"
		nValP := 9
		nValD := 1
	Case cInscr >= "03019023"
		nValP := 0
		nValD := 0
EndCase

nNumA := val(subs(cInscr,08,1))*2
nNumB := val(subs(cInscr,07,1))*3
nNumC := val(subs(cInscr,06,1))*4
nNumD := val(subs(cInscr,05,1))*5
nNumE := val(subs(cInscr,04,1))*6
nNumF := val(subs(cInscr,03,1))*7
nNumG := val(subs(cInscr,02,1))*8
nNumH := val(subs(cInscr,01,1))*9

nTotal := (nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH)+nValP
nResto := mod(nTotal,11)
nSubtr := 11-nResto

Do Case
	Case nSubtr == 10
		cDigit := "0"
	Case nSubtr == 11
		cDigit := alltrim((str(int(nValD))))
	Otherwise
		cDigit := alltrim((str(int(nSubtr))))
EndCase

If cDigit <> cDigOri
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVBA     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ da Bahia                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVBA()

If len(alltrim(M->A2_INSCR)) <> 8 .OR. alltrim(M->A2_INSCR) == "00000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO00" .OR. alltrim(M->A2_INSCR) == "ISENTA00"
	ALERTA3()
Endif

cInscr   := subs(alltrim(M->A2_INSCR),01,6)
cDigOri2 := subs(alltrim(M->A2_INSCR),07,1)
cDigOri1 := subs(alltrim(M->A2_INSCR),08,1)

If subs(cInscr,01,1) <> "6" .AND. subs(cInscr,01,1) <> "7" .AND. subs(cInscr,01,1) <> "9"
	nNumA := val(subs(cInscr,06,1))*2
	nNumB := val(subs(cInscr,05,1))*3
	nNumC := val(subs(cInscr,04,1))*4
	nNumD := val(subs(cInscr,03,1))*5
	nNumE := val(subs(cInscr,02,1))*6
	nNumF := val(subs(cInscr,01,1))*7
	
	nTotal  := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF
	nResto  := mod(nTotal,10)
	
	If nResto  == 0
		cDigit1 := "0"
	Else
		cDigit1 := alltrim((str(int(10-nResto))))
	Endif
	
	nNumAA := val(cDigit1)*2
	nNumBA := val(subs(cInscr,06,1))*3
	nNumCA := val(subs(cInscr,05,1))*4
	nNumDA := val(subs(cInscr,04,1))*5
	nNumEA := val(subs(cInscr,03,1))*6
	nNumFA := val(subs(cInscr,02,1))*7
	nNumGA := val(subs(cInscr,01,1))*8
	
	nTotalA := nNumAA+nNumBA+nNumCA+nNumDA+nNumEA+nNumFA+nNumGA
	nRestoA := mod(nTotalA,10)
	cDigit2 := alltrim((str(int(10-nRestoA))))
	
Else
	
	nNumA := val(subs(cInscr,06,1))*2
	nNumB := val(subs(cInscr,05,1))*3
	nNumC := val(subs(cInscr,04,1))*4
	nNumD := val(subs(cInscr,03,1))*5
	nNumE := val(subs(cInscr,02,1))*6
	nNumF := val(subs(cInscr,01,1))*7
	
	nTotal  := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF
	nResto  := mod(nTotal,11)
	
	If nResto  == 0 .OR. nResto  == 1
		cDigit1 := "0"
	Else
		cDigit1 := alltrim((str(int(11-nResto))))
	Endif
	
	nNumAA := val(cDigit1)*2
	nNumBA := val(subs(cInscr,06,1))*3
	nNumCA := val(subs(cInscr,05,1))*4
	nNumDA := val(subs(cInscr,04,1))*5
	nNumEA := val(subs(cInscr,03,1))*6
	nNumFA := val(subs(cInscr,02,1))*7
	nNumGA := val(subs(cInscr,01,1))*8
	
	nTotalA := nNumAA+nNumBA+nNumCA+nNumDA+nNumEA+nNumFA+nNumGA
	nRestoA := mod(nTotalA,11)
	cDigit2 := alltrim((str(int(11-nRestoA))))
Endif

If cDigit1 <> cDigOri1 .OR. cDigit2 <> cDigOri2
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVCE     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ do Ceara                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVCE()

If len(alltrim(M->A2_INSCR)) <> 9 .OR. alltrim(M->A2_INSCR) == "000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO000" .OR. alltrim(M->A2_INSCR) == "ISENTA000"
	ALERTA3()
Endif


cInscr  := subs(alltrim(M->A2_INSCR),01,8)
cDigOri := subs(alltrim(M->A2_INSCR),09,1)

nNumA := val(subs(cInscr,08,1))*2
nNumB := val(subs(cInscr,07,1))*3
nNumC := val(subs(cInscr,06,1))*4
nNumD := val(subs(cInscr,05,1))*5
nNumE := val(subs(cInscr,04,1))*6
nNumF := val(subs(cInscr,03,1))*7
nNumG := val(subs(cInscr,02,1))*8
nNumH := val(subs(cInscr,01,1))*9

nTotal := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH
nResto := mod(nTotal,11)
nSubtr := 11-nResto

If nSubtr == 10 .OR. nSubtr == 11
	cDigit := "0"
Else
	cDigit := alltrim((str(int(11-nResto))))
Endif

If cDigit <> cDigOri
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVDF     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o           ³±±
±±³          ³ Distrito Federal                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVDF()

If len(alltrim(M->A2_INSCR)) <> 13 .OR. alltrim(M->A2_INSCR) == "0000000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO0000000" .OR. alltrim(M->A2_INSCR) == "ISENTA0000000"
	ALERTA3()
Endif

cInscr   := subs(alltrim(M->A2_INSCR),01,11)
cDigOri1 := subs(alltrim(M->A2_INSCR),12,1)
cDigOri2 := subs(alltrim(M->A2_INSCR),13,1)

cCodEst := subs(cInscr,01,3)
If cCodEst <> "073"
	ALERTA2()
Endif

nNumA := val(subs(cInscr,11,1))*2
nNumB := val(subs(cInscr,10,1))*3
nNumC := val(subs(cInscr,09,1))*4
nNumD := val(subs(cInscr,08,1))*5
nNumE := val(subs(cInscr,07,1))*6
nNumF := val(subs(cInscr,06,1))*7
nNumG := val(subs(cInscr,05,1))*8
nNumH := val(subs(cInscr,04,1))*9
nNumI := val(subs(cInscr,03,1))*2
nNumJ := val(subs(cInscr,02,1))*3
nNumK := val(subs(cInscr,01,1))*4

nTotal  := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH+nNumI+nNumJ+nNumK
nResto  := MOD(nTotal,11)
nSubtr  := 11-nResto

If nSubtr >= 10
	cDigit1 := "0"
Else
	cDigit1 := alltrim((str(int(11-nResto))))
Endif

nNumAA := val(cDigit1)*2
nNumBA := val(subs(cInscr,11,1))*3
nNumCA := val(subs(cInscr,10,1))*4
nNumDA := val(subs(cInscr,09,1))*5
nNumEA := val(subs(cInscr,08,1))*6
nNumFA := val(subs(cInscr,07,1))*7
nNumGA := val(subs(cInscr,06,1))*8
nNumHA := val(subs(cInscr,05,1))*9
nNumIA := val(subs(cInscr,04,1))*2
nNumJA := val(subs(cInscr,03,1))*3
nNumKA := val(subs(cInscr,02,1))*4
nNumLA := val(subs(cInscr,01,1))*5

nTotalA  := nNumAA+nNumBA+nNumCA+nNumDA+nNumEA+nNumFA+nNumGA+nNumHA+nNumIA+nNumJA+nNumKA+nNumLA
nRestoA  := mod(nTotalA,11)
nSubtrA  := 11-nRestoA

If nSubtrA >= 10
	cDigit2 := "0"
Else
	cDigit2 := alltrim((str(int(11-nRestoA))))
Endif

If cDigit1 <> cDigOri1 .OR. cDigit2 <> cDigOri2
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVES     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o Estado    ³±±
±±³          ³ do Espirito Santo                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVES()

If len(alltrim(M->A2_INSCR)) <> 9 .OR. alltrim(M->A2_INSCR) == "000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO000" .OR. alltrim(M->A2_INSCR) == "ISENTA000"
	ALERTA3()
Endif

cInscr  := subs(alltrim(M->A2_INSCR),01,8)
cDigOri := subs(alltrim(M->A2_INSCR),09,1)

nNumA := val(subs(cInscr,08,1))*2
nNumB := val(subs(cInscr,07,1))*3
nNumC := val(subs(cInscr,06,1))*4
nNumD := val(subs(cInscr,05,1))*5
nNumE := val(subs(cInscr,04,1))*6
nNumF := val(subs(cInscr,03,1))*7
nNumG := val(subs(cInscr,02,1))*8
nNumH := val(subs(cInscr,01,1))*9

nTotal := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH
nResto := mod(nTotal,11)
nSubtr := 11-nResto

If nResto < 2
	cDigit := "0"
Else
	cDigit := alltrim((str(int(11-nResto))))
Endif

If cDigit <> cDigOri
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVGO     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o Estado    ³±±
±±³          ³ de Goias                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVGO()

If len(alltrim(M->A2_INSCR)) <> 9 .OR. alltrim(M->A2_INSCR) == "000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO000" .OR. alltrim(M->A2_INSCR) == "ISENTA000"
	ALERTA3()
Endif

cInscrEsp := alltrim(alltrim(M->A2_INSCR))

If cInscrEsp == "110944020" .OR. cInscrEsp == "110944021"
	Return .T.
Endif

cInscr  := subs(alltrim(M->A2_INSCR),01,8)
cDigOri := subs(alltrim(M->A2_INSCR),09,1)
cCodEst := subs(cInscr,01,2)

If cCodEst == "10" .OR. cCodEst == "11" .OR. cCodEst == "15"
	nNumA := val(subs(cInscr,08,1))*2
	nNumB := val(subs(cInscr,07,1))*3
	nNumC := val(subs(cInscr,06,1))*4
	nNumD := val(subs(cInscr,05,1))*5
	nNumE := val(subs(cInscr,04,1))*6
	nNumF := val(subs(cInscr,03,1))*7
	nNumG := val(subs(cInscr,02,1))*8
	nNumH := val(subs(cInscr,01,1))*9
	
	nTotal := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH
	nResto := mod(nTotal,11)
	
	Do Case
		Case nResto == 0
			cDigit := "0"
		Case nResto == 1 .AND. cInscr >= "10103105" .AND. cInscr <= "10119997"
			cDigit := "1"
		Case nResto == 1 .AND. cInscr < "10103105"
			cDigit := "0"
		Case nResto == 1 .AND. cInscr > "10119997"
			cDigit := "0"
		Case nResto > 2
			cDigit := alltrim((str(int(11-nResto))))
	EndCase
Else
	ALERTA3()
Endif

If cDigit <> cDigOri
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVMA     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ do Maranhao                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVMA()

If len(alltrim(M->A2_INSCR)) <> 9 .OR. alltrim(M->A2_INSCR) == "000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO000" .OR. alltrim(M->A2_INSCR) == "ISENTA000"
	ALERTA3()
Endif

cInscr  := subs(alltrim(M->A2_INSCR),01,8)
cDigOri := subs(alltrim(M->A2_INSCR),09,1)

cCodEst := subs(cInscr,01,2)

If cCodEst <> "12"
	ALERTA2()
Endif

nNumA := val(subs(cInscr,08,1))*2
nNumB := val(subs(cInscr,07,1))*3
nNumC := val(subs(cInscr,06,1))*4
nNumD := val(subs(cInscr,05,1))*5
nNumE := val(subs(cInscr,04,1))*6
nNumF := val(subs(cInscr,03,1))*7
nNumG := val(subs(cInscr,02,1))*8
nNumH := val(subs(cInscr,01,1))*9

nTotal := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH
nResto := mod(nTotal,11)

If nResto < 2
	cDigit := "0"
Else
	cDigit := alltrim((str(int(11-nResto))))
Endif

If cDigit <> cDigOri
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVMG     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ de Minas Gerais                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVMG()

If len(alltrim(M->A2_INSCR)) <> 13 .OR. alltrim(M->A2_INSCR) == "0000000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO0000000" .OR. alltrim(M->A2_INSCR) == "ISENTA0000000"
	ALERTA3()
Endif

cInscr   := subs(alltrim(M->A2_INSCR),01,11)
cInscrT  := subs(cInscr,01,3)+"0"+subs(cInscr,04,8)

cDigOri1 := subs(alltrim(M->A2_INSCR),12,1)
cDigOri2 := subs(alltrim(M->A2_INSCR),13,1)

nNumA  := val(subs(cInscrT,01,1))*1

If subs(cInscrT,02,1) > "4"
	cSubsB := alltrim(str(val(subs(cInscrT,02,1))*2))
	nNumB  := val(subs(cSubsB,01,1))
	nNumBB := val(subs(cSubsB,02,1))
Else
	nNumB  := val(subs(cInscrT,02,1))*2
	nNumBB := 0
Endif

nNumC  := val(subs(cInscrT,03,1))*1
nNumD  := 0
nNumE  := val(subs(cInscrT,05,1))*1

If subs(cInscrT,06,1) > "4"
	cSubsF := alltrim(str(val(subs(cInscrT,06,1))*2))
	nNumF  := val(subs(cSubsF,01,1))
	nNumFF := val(subs(cSubsF,02,1))
Else
	nNumF  := val(subs(cInscrT,06,1))*2
	nNumFF := 0
Endif

nNumG  := val(subs(cInscrT,07,1))*1

If subs(cInscrT,08,1) > "4"
	cSubsH := alltrim(str(val(subs(cInscrT,08,1))*2))
	nNumH  := val(subs(cSubsH,01,1))
	nNumHH := val(subs(cSubsH,02,1))
Else
	nNumH  := val(subs(cInscrT,08,1))*2
	nNumHH := 0
Endif

nNumI  := val(subs(cInscrT,09,1))*1

If subs(cInscrT,10,1) > "4"
	cSubsJ := alltrim(str(val(subs(cInscrT,10,1))*2))
	nNumJ  := val(subs(cSubsJ,01,1))
	nNumJJ := val(subs(cSubsJ,02,1))
Else
	nNumJ  := val(subs(cInscrT,10,1))*2
	nNumJJ := 0
Endif

nNumK  := val(subs(cInscrT,11,1))*1

If subs(cInscrT,12,1) > "4"
	cSubsL := alltrim(str(val(subs(cInscrT,12,1))*2))
	nNumL  := val(subs(cSubsL,01,1))
	nNumLL := val(subs(cSubsL,02,1))
Else
	nNumL  := val(subs(cInscrT,12,1))*2
	nNumLL := 0
Endif

nTotal := nNumA+nNumB+nNumBB+nNumC+nNumD+nNumE+nNumF+nNumFF+nNumG+nNumH+nNumHH+nNumI+nNumJ+nNumJJ+nNumK+nNumL+nNumLL

Do Case
	Case nTotal >= 0 .AND. nTotal <= 9
		cDigit1 := alltrim((str(int(10-nTotal))))
	Case nTotal >= 10 .AND. nTotal <= 19
		cDigit1 := alltrim((str(int(20-nTotal))))
	Case nTotal >= 20 .AND. nTotal <= 29
		cDigit1 := alltrim((str(int(30-nTotal))))
	Case nTotal >= 30 .AND. nTotal <= 39
		cDigit1 := alltrim((str(int(40-nTotal))))
	Case nTotal >= 40 .AND. nTotal <= 49
		cDigit1 := alltrim((str(int(50-nTotal))))
	Case nTotal >= 50 .AND. nTotal <= 59
		cDigit1 := alltrim((str(int(60-nTotal))))
	Case nTotal >= 60 .AND. nTotal <= 69
		cDigit1 := alltrim((str(int(70-nTotal))))
	Case nTotal >= 70 .AND. nTotal <= 79
		cDigit1 := alltrim((str(int(80-nTotal))))
	Case nTotal >= 80 .AND. nTotal <= 89
		cDigit1 := alltrim((str(int(90-nTotal))))
	Case nTotal >= 90 .AND. nTotal <= 99
		cDigit1 := alltrim((str(int(100-nTotal))))
EndCase

nNumAA := val(cDigit1)*2
nNumBA := val(subs(cInscr,11,1))*3
nNumCA := val(subs(cInscr,10,1))*4
nNumDA := val(subs(cInscr,09,1))*5
nNumEA := val(subs(cInscr,08,1))*6
nNumFA := val(subs(cInscr,07,1))*7
nNumGA := val(subs(cInscr,06,1))*8
nNumHA := val(subs(cInscr,05,1))*9
nNumIA := val(subs(cInscr,04,1))*10
nNumJA := val(subs(cInscr,03,1))*11
nNumKA := val(subs(cInscr,02,1))*2
nNumLA := val(subs(cInscr,01,1))*3

nTotalA  := nNumAA+nNumBA+nNumCA+nNumDA+nNumEA+nNumFA+nNumGA+nNumHA+nNumIA+nNumJA+nNumKA+nNumLA
nRestoA  := mod(nTotalA,11)

If nRestoA < 2
	cDigit2 := "0"
Else
	cDigit2 := alltrim((str(int(11-nRestoA))))
Endif

If cDigit1 <> cDigOri1 .OR. cDigit2 <> cDigOri2
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVMS     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ do Mato Grosso do Sul                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVMS()

If len(alltrim(M->A2_INSCR)) <> 9 .OR. alltrim(M->A2_INSCR) == "000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO000" .OR. alltrim(M->A2_INSCR) == "ISENTA000"
	ALERTA3()
Endif

cInscr  := subs(alltrim(M->A2_INSCR),01,8)
cDigOri := subs(alltrim(M->A2_INSCR),09,1)

cCodEst := subs(cInscr,01,2)

If cCodEst <> "28"
	ALERTA2()
Endif

nNumA := val(subs(cInscr,08,1))*2
nNumB := val(subs(cInscr,07,1))*3
nNumC := val(subs(cInscr,06,1))*4
nNumD := val(subs(cInscr,05,1))*5
nNumE := val(subs(cInscr,04,1))*6
nNumF := val(subs(cInscr,03,1))*7
nNumG := val(subs(cInscr,02,1))*8
nNumH := val(subs(cInscr,01,1))*9

nTotal := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH
nResto := mod(nTotal,11)
nSubtr := 11-nResto

If nResto == 0 .OR. nSubtr > 9
	cDigit := "0"
Else
	cDigit := alltrim((str(int(11-nResto))))
Endif

If cDigit <> cDigOri
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVMT     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ do Mato Grosso                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVMT()

If len(alltrim(M->A2_INSCR)) <> 11 .OR. alltrim(M->A2_INSCR) == "00000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO00000" .OR. alltrim(M->A2_INSCR) == "ISENTA00000"
	ALERTA3()
Endif

cInscr  := subs(alltrim(M->A2_INSCR),01,10)
cDigOri := subs(alltrim(M->A2_INSCR),11,1)

nNumA := val(subs(cInscr,10,1))*2
nNumB := val(subs(cInscr,09,1))*3
nNumC := val(subs(cInscr,08,1))*4
nNumD := val(subs(cInscr,07,1))*5
nNumE := val(subs(cInscr,06,1))*6
nNumF := val(subs(cInscr,05,1))*7
nNumG := val(subs(cInscr,04,1))*8
nNumH := val(subs(cInscr,03,1))*9
nNumI := val(subs(cInscr,02,1))*2
nNumJ := val(subs(cInscr,01,1))*3

nTotal := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH+nNumI+nNumJ
nResto := mod(nTotal,11)
nSubtr := 11-nResto

If nResto == 0 .OR. nResto == 1
	cDigit := "0"
Else
	cDigit := alltrim((str(int(11-nResto))))
Endif

If cDigit <> cDigOri
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVPA     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ do Para                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVPA()

If len(alltrim(M->A2_INSCR)) <> 9 .OR. alltrim(M->A2_INSCR) == "000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO000" .OR. alltrim(M->A2_INSCR) == "ISENTA000"
	ALERTA3()
Endif


cInscr  := subs(alltrim(M->A2_INSCR),01,8)
cDigOri := subs(alltrim(M->A2_INSCR),09,1)

cCodEst := subs(cInscr,01,2)

If cCodEst <> "15"
	ALERTA2()
Endif

nNumA := val(subs(cInscr,08,1))*2
nNumB := val(subs(cInscr,07,1))*3
nNumC := val(subs(cInscr,06,1))*4
nNumD := val(subs(cInscr,05,1))*5
nNumE := val(subs(cInscr,04,1))*6
nNumF := val(subs(cInscr,03,1))*7
nNumG := val(subs(cInscr,02,1))*8
nNumH := val(subs(cInscr,01,1))*9

nTotal := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH
nResto := mod(nTotal,11)

If nResto == 0 .OR. nResto == 1
	cDigit := "0"
Else
	cDigit := alltrim((str(int(11-nResto))))
Endif

If cDigit <> cDigOri
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVPB     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ do Paraiba                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVPB()

If len(alltrim(M->A2_INSCR)) <> 9 .OR. alltrim(M->A2_INSCR) == "000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO000" .OR. alltrim(M->A2_INSCR) == "ISENTA000"
	ALERTA3()
Endif

cInscr  := subs(alltrim(M->A2_INSCR),01,8)
cDigOri := subs(alltrim(M->A2_INSCR),09,1)

nNumA := val(subs(cInscr,08,1))*2
nNumB := val(subs(cInscr,07,1))*3
nNumC := val(subs(cInscr,06,1))*4
nNumD := val(subs(cInscr,05,1))*5
nNumE := val(subs(cInscr,04,1))*6
nNumF := val(subs(cInscr,03,1))*7
nNumG := val(subs(cInscr,02,1))*8
nNumH := val(subs(cInscr,01,1))*9

nTotal := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH
nResto := mod(nTotal,11)
nSubtr := 11-nResto

If nSubtr == 10 .OR. nSubtr == 11
	cDigit := "0"
Else
	cDigit := alltrim((str(int(11-nResto))))
Endif

If cDigit <> cDigOri
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVPE     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ de Pernambuco                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVPE()

If len(alltrim(M->A2_INSCR)) <> 14 .OR. alltrim(M->A2_INSCR) == "00000000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO00000000" .OR. alltrim(M->A2_INSCR) == "ISENTA00000000"
	ALERTA3()
Endif

cInscr  := subs(alltrim(M->A2_INSCR),01,13)
cDigOri := subs(alltrim(M->A2_INSCR),14,1)

nNumA := val(subs(cInscr,13,1))*2
nNumB := val(subs(cInscr,12,1))*3
nNumC := val(subs(cInscr,11,1))*4
nNumD := val(subs(cInscr,10,1))*5
nNumE := val(subs(cInscr,09,1))*6
nNumF := val(subs(cInscr,08,1))*7
nNumG := val(subs(cInscr,07,1))*8
nNumH := val(subs(cInscr,06,1))*9
nNumI := val(subs(cInscr,05,1))*1
nNumJ := val(subs(cInscr,04,1))*1
nNumK := val(subs(cInscr,03,1))*3
nNumL := val(subs(cInscr,02,1))*4
nNumM := val(subs(cInscr,01,1))*5

nTotal := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH+nNumI+nNumJ+nNumK+nNumL+nNumM
nResto := mod(nTotal,11)
nSubtr := 11-nResto

If nSubtr > 10
	cDigit := "0"
Else
	cDigit := alltrim((str(int(11-nResto))))
Endif

If cDigit <> cDigOri
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVPI     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ do Piaui                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVPI()

If len(alltrim(M->A2_INSCR)) <> 9 .OR. alltrim(M->A2_INSCR) == "000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO000" .OR. alltrim(M->A2_INSCR) == "ISENTA000"
	ALERTA3()
Endif

cInscr  := subs(alltrim(M->A2_INSCR),01,8)
cDigOri := subs(alltrim(M->A2_INSCR),09,1)

nNumA := val(subs(cInscr,08,1))*2
nNumB := val(subs(cInscr,07,1))*3
nNumC := val(subs(cInscr,06,1))*4
nNumD := val(subs(cInscr,05,1))*5
nNumE := val(subs(cInscr,04,1))*6
nNumF := val(subs(cInscr,03,1))*7
nNumG := val(subs(cInscr,02,1))*8
nNumH := val(subs(cInscr,01,1))*9

nTotal := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH
nResto := mod(nTotal,11)

If nResto < 2
	cDigit := "0"
Else
	cDigit := alltrim((str(int(11-nResto))))
Endif

If cDigit <> cDigOri
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVPR     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ do Parana                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVPR()

If len(alltrim(M->A2_INSCR)) <> 10 .OR. alltrim(M->A2_INSCR) == "0000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO0000" .OR. alltrim(M->A2_INSCR) == "ISENTA0000"
	ALERTA3()
Endif

cInscr   := subs(alltrim(M->A2_INSCR),01,8)
cDigOri1 := subs(alltrim(M->A2_INSCR),09,1)
cDigOri2 := subs(alltrim(M->A2_INSCR),10,1)

nNumA := val(subs(cInscr,08,1))*2
nNumB := val(subs(cInscr,07,1))*3
nNumC := val(subs(cInscr,06,1))*4
nNumD := val(subs(cInscr,05,1))*5
nNumE := val(subs(cInscr,04,1))*6
nNumF := val(subs(cInscr,03,1))*7
nNumG := val(subs(cInscr,02,1))*2
nNumH := val(subs(cInscr,01,1))*3

nTotal := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH
nResto := mod(nTotal,11)

If nResto == 0 .OR. nResto == 1
	cDigit1 := "0"
Else
	cDigit1 := alltrim((str(int(11-nResto))))
Endif

nNumAA := val(cDigit1)*2
nNumBA := val(subs(cInscr,08,1))*3
nNumCA := val(subs(cInscr,07,1))*4
nNumDA := val(subs(cInscr,06,1))*5
nNumEA := val(subs(cInscr,05,1))*6
nNumFA := val(subs(cInscr,04,1))*7
nNumGA := val(subs(cInscr,03,1))*2
nNumHA := val(subs(cInscr,02,1))*3
nNumIA := val(subs(cInscr,01,1))*4

nTotalA  := nNumAA+nNumBA+nNumCA+nNumDA+nNumEA+nNumFA+nNumGA+nNumHA+nNumIA
nRestoA  := mod(nTotalA,11)

If nRestoA == 0 .OR. nRestoA == 1
	cDigit2 := "0"
Else
	cDigit2 := alltrim((str(int(11-nRestoA))))
Endif

If cDigit1 <> cDigOri1 .OR. cDigit2 <> cDigOri2
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVRJ     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ do Rio de Janeiro                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVRJ()

If len(alltrim(M->A2_INSCR)) <> 8 .OR. alltrim(M->A2_INSCR) == "00000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO00" .OR. alltrim(M->A2_INSCR) == "ISENTA00"
	ALERTA3()
Endif

cInscr  := subs(alltrim(M->A2_INSCR),01,7)
cDigOri := subs(alltrim(M->A2_INSCR),08,1)

nNumA := val(subs(cInscr,07,1))*2
nNumB := val(subs(cInscr,06,1))*3
nNumC := val(subs(cInscr,05,1))*4
nNumD := val(subs(cInscr,04,1))*5
nNumE := val(subs(cInscr,03,1))*6
nNumF := val(subs(cInscr,02,1))*7
nNumG := val(subs(cInscr,01,1))*2

nTotal := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG
nResto := mod(nTotal,11)

If nResto < 2
	cDigit := "0"
Else
	cDigit := alltrim((str(int(11-nResto))))
Endif

If cDigit <> cDigOri
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVRN     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ do Rio Grande do Norte                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVRN()

If len(alltrim(M->A2_INSCR)) <> 9 .OR. alltrim(M->A2_INSCR) == "000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO000" .OR. alltrim(M->A2_INSCR) == "ISENTA000"
	ALERTA3()
Endif

cInscr  := subs(alltrim(M->A2_INSCR),01,8)
cDigOri := subs(alltrim(M->A2_INSCR),09,1)

nNumA := val(subs(cInscr,08,1))*2
nNumB := val(subs(cInscr,07,1))*3
nNumC := val(subs(cInscr,06,1))*4
nNumD := val(subs(cInscr,05,1))*5
nNumE := val(subs(cInscr,04,1))*6
nNumF := val(subs(cInscr,03,1))*7
nNumG := val(subs(cInscr,02,1))*8
nNumH := val(subs(cInscr,01,1))*9

nTotal := (nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH)*10
nResto := mod(nTotal,11)

If nResto == 10
	cDigit := "0"
Else
	cDigit := alltrim((str(int(nResto))))
Endif

If cDigit <> cDigOri
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVRO     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ de Rondonia                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVRO()

If len(alltrim(M->A2_INSCR)) <> 9 .OR. alltrim(M->A2_INSCR) == "000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO000" .OR. alltrim(M->A2_INSCR) == "ISENTA000"
	ALERTA3()
Endif

cInscr  := subs(alltrim(M->A2_INSCR),01,8)
cDigOri := subs(alltrim(M->A2_INSCR),09,1)

nNumA := val(subs(cInscr,08,1))*2
nNumB := val(subs(cInscr,07,1))*3
nNumC := val(subs(cInscr,06,1))*4
nNumD := val(subs(cInscr,05,1))*5
nNumE := val(subs(cInscr,04,1))*6

nTotal := nNumA+nNumB+nNumC+nNumD+nNumE
nResto := mod(nTotal,11)
nSubtr := 11-nResto

If nSubtr >= 10
	cDigit := alltrim((str(int(nSubtr-10))))
Else
	cDigit := alltrim((str(int(11-nResto))))
Endif

If cDigit <> cDigOri
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVRR     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ de Roraima                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVRR()

If len(alltrim(M->A2_INSCR)) <> 9 .OR. alltrim(M->A2_INSCR) == "000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO000" .OR. alltrim(M->A2_INSCR) == "ISENTA000"
	ALERTA3()
Endif

cInscr  := subs(alltrim(M->A2_INSCR),01,8)
cDigOri := subs(alltrim(M->A2_INSCR),09,1)

cCodEst := subs(cInscr,01,2)

If cCodEst <> "24"
	ALERTA2()
Endif

nNumA := val(subs(cInscr,01,1))*1
nNumB := val(subs(cInscr,02,1))*2
nNumC := val(subs(cInscr,03,1))*3
nNumD := val(subs(cInscr,04,1))*4
nNumE := val(subs(cInscr,05,1))*5
nNumF := val(subs(cInscr,06,1))*6
nNumG := val(subs(cInscr,07,1))*7
nNumH := val(subs(cInscr,08,1))*8

nTotal := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH
nResto := mod(nTotal,9)
cDigit := alltrim((str(int(nResto))))

If cDigit <> cDigOri
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVRS     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ do Rio Grande do Sul                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVRS()

If len(alltrim(M->A2_INSCR)) <> 10 .OR. alltrim(M->A2_INSCR) == "0000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO0000" .OR. alltrim(M->A2_INSCR) == "ISENTA0000"
	ALERTA3()
Endif

cInscr  := subs(alltrim(M->A2_INSCR),01,9)
cDigOri := subs(alltrim(M->A2_INSCR),10,1)

nNumA := val(subs(cInscr,09,1))*2
nNumB := val(subs(cInscr,08,1))*3
nNumC := val(subs(cInscr,07,1))*4
nNumD := val(subs(cInscr,06,1))*5
nNumE := val(subs(cInscr,05,1))*6
nNumF := val(subs(cInscr,04,1))*7
nNumG := val(subs(cInscr,03,1))*8
nNumH := val(subs(cInscr,02,1))*9
nNumI := val(subs(cInscr,01,1))*2

nTotal := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH+nNumI
nResto := mod(nTotal,11)

If nResto < 2
	cDigit := "0"
Else
	cDigit := alltrim((str(int(11-nResto))))
Endif

If cDigit <> cDigOri
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVSC     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ de Santa Catarina                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVSC()

If len(alltrim(M->A2_INSCR)) <> 9 .OR. alltrim(M->A2_INSCR) == "000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO000" .OR. alltrim(M->A2_INSCR) == "ISENTA000"
	ALERTA3()
Endif

cInscr  := subs(alltrim(M->A2_INSCR),01,8)
cDigOri := subs(alltrim(M->A2_INSCR),09,1)

nNumA := val(subs(cInscr,08,1))*2
nNumB := val(subs(cInscr,07,1))*3
nNumC := val(subs(cInscr,06,1))*4
nNumD := val(subs(cInscr,05,1))*5
nNumE := val(subs(cInscr,04,1))*6
nNumF := val(subs(cInscr,03,1))*7
nNumG := val(subs(cInscr,02,1))*8
nNumH := val(subs(cInscr,01,1))*9

nTotal := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH
nResto := mod(nTotal,11)

If nResto < 2
	cDigit := "0"
Else
	cDigit := alltrim((str(int(11-nResto))))
Endif

If cDigit <> cDigOri
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVSE     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ de Sergipe                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVSE()

If len(alltrim(M->A2_INSCR)) <> 9 .OR. alltrim(M->A2_INSCR) == "000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO000" .OR. alltrim(M->A2_INSCR) == "ISENTA000"
	ALERTA3()
Endif

cInscr  := subs(alltrim(M->A2_INSCR),01,8)
cDigOri := subs(alltrim(M->A2_INSCR),09,1)

nNumA := val(subs(cInscr,08,1))*2
nNumB := val(subs(cInscr,07,1))*3
nNumC := val(subs(cInscr,06,1))*4
nNumD := val(subs(cInscr,05,1))*5
nNumE := val(subs(cInscr,04,1))*6
nNumF := val(subs(cInscr,03,1))*7
nNumG := val(subs(cInscr,02,1))*8
nNumH := val(subs(cInscr,01,1))*9

nTotal := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH
nResto := mod(nTotal,11)

If nResto < 2
	cDigit := "0"
Else
	cDigit := alltrim((str(int(11-nResto))))
Endif

If cDigit <> cDigOri
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVSP     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ de Sao Paulo                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVSP()

If subs(alltrim(M->A2_INSCR),01,1) <> "P"
	
	If len(alltrim(M->A2_INSCR)) <> 12 .OR. alltrim(M->A2_INSCR) == "000000000000";
		.OR. alltrim(M->A2_INSCR) == "ISENTO000000" .OR. alltrim(M->A2_INSCR) == "ISENTA000000"
		ALERTA3()
	Endif
	
	cInscr   := subs(alltrim(M->A2_INSCR),01,11)
	cDigOri1 := subs(alltrim(M->A2_INSCR),09,1)
	cDigOri2 := subs(alltrim(M->A2_INSCR),12,1)
	
	nNumA := val(subs(cInscr,01,1))*1
	nNumB := val(subs(cInscr,02,1))*3
	nNumC := val(subs(cInscr,03,1))*4
	nNumD := val(subs(cInscr,04,1))*5
	nNumE := val(subs(cInscr,05,1))*6
	nNumF := val(subs(cInscr,06,1))*7
	nNumG := val(subs(cInscr,07,1))*8
	nNumH := val(subs(cInscr,08,1))*10
	
	nTotal := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH
	nResto := mod(nTotal,11)
	
	If nResto == 10
		cDigit1 := "0"
	Else
		cDigit1 := alltrim((str(int(nResto))))
	Endif
	
	nNumAA := val(subs(cInscr,11,1))*2
	nNumBA := val(subs(cInscr,10,1))*3
	nNumCA := val(cDigit1)*4
	nNumDA := val(subs(cInscr,08,1))*5
	nNumEA := val(subs(cInscr,07,1))*6
	nNumFA := val(subs(cInscr,06,1))*7
	nNumGA := val(subs(cInscr,05,1))*8
	nNumHA := val(subs(cInscr,04,1))*9
	nNumIA := val(subs(cInscr,03,1))*10
	nNumJA := val(subs(cInscr,02,1))*2
	nNumKA := val(subs(cInscr,01,1))*3
	
	nTotalA  := nNumAA+nNumBA+nNumCA+nNumDA+nNumEA+nNumFA+nNumGA+nNumHA+nNumIA+nNumJA+nNumKA
	nRestoA  := mod(nTotalA,11)
	
	If nRestoA == 10
		cDigit2 := "0"
	Else
		cDigit2 := alltrim((str(int(nRestoA))))
	Endif
	
	If cDigit1 <> cDigOri1 .OR. cDigit2 <> cDigOri2
		ALERTA3()
	Endif
	
Else
	
	If len(alltrim(M->A2_INSCR)) <> 14 .OR. alltrim(M->A2_INSCR) == "00000000000000";
		.OR. alltrim(M->A2_INSCR) == "ISENTO00000000" .OR. alltrim(M->A2_INSCR) == "ISENTA00000000"
		ALERTA3()
	Endif
	
	cInscr  := subs(alltrim(M->A2_INSCR),02,8)
	cDigOri := subs(alltrim(M->A2_INSCR),10,1)
	
	nNumA := val(subs(cInscr,01,1))*1
	nNumB := val(subs(cInscr,02,1))*3
	nNumC := val(subs(cInscr,03,1))*4
	nNumD := val(subs(cInscr,04,1))*5
	nNumE := val(subs(cInscr,05,1))*6
	nNumF := val(subs(cInscr,06,1))*7
	nNumG := val(subs(cInscr,07,1))*8
	nNumH := val(subs(cInscr,08,1))*10
	
	nTotal := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH
	nResto := mod(nTotal,11)
	
	If nResto == 10
		cDigit := "0"
	Else
		cDigit := alltrim((str(int(nResto))))
	Endif
	
	If cDigit <> cDigOri
		ALERTA3()
	Endif
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DVTO     ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Inscricao Estadual e valida para o estado    ³±±
±±³          ³ do Tocantins                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DVTO()

If len(alltrim(M->A2_INSCR)) <> 11 .OR. alltrim(M->A2_INSCR) == "00000000000";
	.OR. alltrim(M->A2_INSCR) == "ISENTO00000" .OR. alltrim(M->A2_INSCR) == "ISENTA00000"
	ALERTA3()
Endif

cInscr  := subs(alltrim(M->A2_INSCR),01,10)
cDigOri := subs(alltrim(M->A2_INSCR),11,1)

nNumA := val(subs(cInscr,10,1))*2
nNumB := val(subs(cInscr,09,1))*3
nNumC := val(subs(cInscr,08,1))*4
nNumD := val(subs(cInscr,07,1))*5
nNumE := val(subs(cInscr,06,1))*6
nNumF := val(subs(cInscr,05,1))*7
nNumG := val(subs(cInscr,02,1))*8
nNumH := val(subs(cInscr,01,1))*9

nTotal := nNumA+nNumB+nNumC+nNumD+nNumE+nNumF+nNumG+nNumH
nResto := mod(nTotal,11)

If nResto < 2
	cDigit := "0"
Else
	cDigit := alltrim((str(int(11-nResto))))
Endif

If cDigit <> cDigOri
	ALERTA3()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ALERTA2  ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Envia mensagem informando que a sigla do Estado esta       ³±±
±±³          ³ incorreta                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ALERTA2()

MsgBox ("Sigla do Estado invalida!","Atencao...","ALERT")

Return .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ALERTA2  ³ Autor ³ Paulo Sergio Quateli  ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Envia mensagem informando que a Inscricao Estadual esta    ³±±
±±³          ³ incorreta                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastros                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ALERTA3()

MsgBox ("Inscricao Estadual invalida!","Atencao...","ALERT")
_lRet := .F.

Return .T.

