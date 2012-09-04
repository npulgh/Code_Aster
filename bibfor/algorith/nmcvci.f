      SUBROUTINE NMCVCI(CHARGE,INFOCH,FOMULT,NUMEDD,DEPMOI,
     &           INSTAP,CNCINE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 04/09/2012   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.
C
C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.
C
C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE PELLET J.PELLET
      IMPLICIT NONE


C BUT : CALCULER LE CHAM_NO CNCINE QUI CONTIENT  L'INCREMENT DE
C       DEPLACEMENT IMPOSE PAR LES CHARGES CINEMATIQUES.
C       POUR CELA, ON FAIT LA DIFFERENCE ENTRE LES INSTANTS "+" ET "-"
C       MAIS POUR L'INSTANT "-", IL FAUT PARTIR DU "VRAI" CHAMP
C       DE DEPLACEMENT.
C----------------------------------------------------------------------
      INCLUDE 'jeveux.h'
      CHARACTER*24 CHARGE, INFOCH, FOMULT,NUMEDD,CNCINE
      CHARACTER*19 DEPMOI
      CHARACTER*24 L2CNCI(2),CNCINM,CNCINP
      CHARACTER*8 CHAR1
      REAL*8 INSTAP, COEFR(2)
      INTEGER JDLCI,NEQ,IEQ,NEQ2,JCNCIM,IRET,J1,JINFC,ICHAR
      INTEGER NBCHAR, IEXI,JLCHAR
      CHARACTER*1 KBID ,TYPCH(2)
      LOGICAL LVCINE
C----------------------------------------------------------------------

      CALL JEMARQ()

C     -- CREATION DE CNCINE = 0. PARTOUT :
C     --------------------------------------
      CALL EXISD('CHAMP_GD',CNCINE,IRET)
      IF (IRET.EQ.0) CALL VTCREB (CNCINE,NUMEDD,'V','R',NEQ)
      CALL JELIRA(CNCINE(1:19)//'.VALE','LONMAX',NEQ,KBID)
      CALL JELIRA(DEPMOI(1:19)//'.VALE','LONMAX',NEQ2,KBID)
      CALL ASSERT(NEQ.EQ.NEQ2)
      CALL JEVEUO(CNCINE(1:19)//'.VALE','E',J1)
      DO 2, IEQ=1,NEQ
         ZR(J1-1+IEQ)=0.D0
2     CONTINUE


C     -- Y-A-T-IL DES CHARGES CINEMATIQUES ?
C     -----------------------------------------------------------------
      LVCINE=.FALSE.
      CALL JEVEUO(INFOCH,'L',JINFC)
      DO 10 ICHAR = 1,ZI(JINFC)
        IF (ZI(JINFC+ICHAR).LT.0) LVCINE=.TRUE.
   10 CONTINUE

C     -- Y-A-T-IL DES CHARGES CONTENANT DES CHARGES CINEMATIQUES ?
C     -----------------------------------------------------------------
      CALL JEVEUO(CHARGE,'L',JLCHAR)
      CALL JELIRA(CHARGE,'LONMAX',NBCHAR,KBID)
      DO 11 ICHAR = 1,NBCHAR
        CHAR1=ZK24(JLCHAR-1+ICHAR)(1:8)
        CALL JEEXIN(CHAR1//'.ELIM      .AFCK',IEXI)
        IF (IEXI.GT.0) LVCINE=.TRUE.
   11 CONTINUE

C     -- S'IL N'Y A PAS DE CHARGES CINEMATIQUES, IL N'Y A RIEN A FAIRE:
C     -----------------------------------------------------------------
      IF (.NOT.LVCINE) GO TO 9999


C     -- S'IL Y A DES CHARGES CINEMATIQUES :
C     -----------------------------------------------------------------
      CNCINM='&&NMCHAR.CNCIMM'
      CNCINP='&&NMCHAR.CNCIMP'


C     CALCUL DE UIMP+ :
C     ---------------------
      CALL ASCAVC(CHARGE,INFOCH,FOMULT,NUMEDD,INSTAP,CNCINP)
      CALL JEVEUO(CNCINP(1:19)//'.DLCI','L',JDLCI)


C     CALCUL DE UIMP- : C'EST U- LA OU ON IMPOSE LE DEPLACEMENT
C                       ET 0. AILLEURS
C     ---------------------------------------------------------
      CALL COPISD('CHAMP_GD','V',DEPMOI,CNCINM)
      CALL JEVEUO(CNCINM(1:19)//'.VALE','E',JCNCIM)
      DO 1, IEQ=1,NEQ
           IF (ZI(JDLCI-1+IEQ).EQ.0) THEN
             ZR(JCNCIM-1+IEQ)=0.D0
           END IF
1     CONTINUE

C     DIFFERENCE UIMP+ - UIMP- :
C     ---------------------------
      COEFR(1)=-1.D0
      COEFR(2)=+1.D0
      L2CNCI(1)=CNCINM
      L2CNCI(2)=CNCINP
      TYPCH(1)='R'
      TYPCH(2)='R'
      CALL VTCMBL(2,TYPCH,COEFR,TYPCH,L2CNCI,TYPCH,CNCINE)

C     MENAGE :
C     ---------
      CALL DETRSD('CHAM_NO',CNCINM)
      CALL DETRSD('CHAM_NO',CNCINP)

9999  CONTINUE
      CALL JEDEMA()

      END
