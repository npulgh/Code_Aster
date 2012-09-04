      SUBROUTINE ASCAVC(LCHAR,INFCHA,FOMULT,NUMEDD,INST,VCI)
      IMPLICIT NONE

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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE PELLET J.PELLET

      INCLUDE 'jeveux.h'
      CHARACTER*24 LCHAR,INFCHA,FOMULT
      CHARACTER*(*) VCI,NUMEDD
      REAL*8 INST
C ----------------------------------------------------------------------
C BUT  :  CALCUL DU CHAM_NO CONTENANT LE VECTEUR LE CINEMATIQUE
C ---     ASSOCIE A LA LISTE DE CHAR_CINE_* LCHAR A UN INSTANT INST
C         AVEC LES FONCTIONS MULTIPLICATIVES FOMULT.
C ----------------------------------------------------------------------
C IN  K*24 LCHAR : NOM DE L'OJB S V K24 CONTENANT LA LISTE DES CHARGES
C IN  K*19 INFCHA : NOM DE L'OJB S V I CONTENANT LA LISTE DES INFO.
C IN  K*24 FOMULT : NOM DE L'OJB S V K24 CONTENANT LA LISTE DES FONC.
C IN  K*14 NUMEDD  : NOM DE LA NUMEROTATION SUPPORTANT LE CHAM_NO
C IN  R*8  INST   : VALE DU PARAMETRE INST.
C VAR/JXOUT  K*19 VCI    :  CHAM_NO RESULTAT
C   -------------------------------------------------------------------
C-----------------------------------------------------------------------
C----------------------------------------------------------------------
C     VARIABLES LOCALES
C----------------------------------------------------------------------
      INTEGER IDCHAR,JINFC,IDFOMU,NCHTOT,NCHCI,ICHAR,ICINE,ILCHNO
      INTEGER ICHCI,IBID,IFM,NIV,NEQ,IEQ,JDLCI2,JDLCI,IEQMUL
      CHARACTER*8 NEWNOM,KBID,NOMNO,NOMCMP,TYDDL
      CHARACTER*19 CHARCI,CHAMNO,VCI2,LIGREL
      CHARACTER*24 VACHCI,VALK(2),INFOBL
      CHARACTER*8 CHARGE
      INTEGER     IREFN,IER
      LOGICAL     LFETI
      DATA CHAMNO/'&&ASCAVC.???????'/
      DATA VACHCI/'&&ASCAVC.LISTE_CI'/
      DATA CHARCI/'&&ASCAVC.LISTE_CHI'/
C----------------------------------------------------------------------


      CALL JEMARQ()
      IF (VCI.EQ.' ') VCI='&&ASCAVC.VCI'
      VCI2=VCI
C RECUPERATION ET MAJ DU NIVEAU D'IMPRESSION
      CALL INFNIV(IFM,NIV)

C --- FETI OR NOT ?
      LFETI = .FALSE.
      CALL JEVEUO(NUMEDD(1:14)//'.NUME.REFN','L',IREFN)
      IF (ZK24(IREFN+2).EQ.'FETI') THEN
        LFETI=.TRUE.
      ENDIF

      NEWNOM='.0000000'

      CALL JEDETR(VACHCI)
      CALL JEDETR(VCI2//'.DLCI')
      CALL JEVEUO(LCHAR,'L',IDCHAR)
      CALL JEVEUO(INFCHA,'L',JINFC)
      CALL JEVEUO(FOMULT,'L',IDFOMU)

      NCHTOT = ZI(JINFC)
      NCHCI = 0
      IEQMUL=0

      DO 10 ICHAR = 1,NCHTOT
        ICINE = ZI(JINFC+ICHAR)
        IF (ICINE.LT.0) NCHCI=NCHCI+1
C       -- UNE CHARGE NON "CINEMATIQUE" PEUT EN CONTENIR UNE :
        CHARGE=ZK24(IDCHAR-1+ICHAR)
        CALL JEEXIN(CHARGE//'.ELIM      .AFCK',IER)
        IF (IER.GT.0) NCHCI=NCHCI+1
   10 CONTINUE


      CALL WKVECT(VACHCI,'V V K24',MAX(NCHCI,1),ILCHNO)

C     -- S'IL N'Y A PAS DE CHARGES CINEMATIQUES, ON CREE UN CHAMP NUL:
      IF (NCHCI.EQ.0) THEN
        CALL GCNCO2(NEWNOM)
        CHAMNO(10:16) = NEWNOM(2:8)
        CALL CORICH('E',CHAMNO,-2,IBID)
        CALL VTCREB(CHAMNO,NUMEDD,'V','R',NEQ)
        ZK24(ILCHNO-1+1) = CHAMNO


C     -- S'IL Y A DES CHARGES CINEMATIQUES :
      ELSE
        IF (LFETI) CALL U2MESS('F','ALGORITH_16')

        ICHCI = 0
        CALL DISMOI('F','NB_EQUA',NUMEDD,'NUME_DDL',NEQ,KBID,IER)
        CALL WKVECT(VCI2//'.DLCI','V V I',NEQ,JDLCI2)
        DO 20 ICHAR = 1,NCHTOT
          CHARGE=ZK24(IDCHAR-1+ICHAR)
          ICINE = ZI(JINFC+ICHAR)
          CALL JEEXIN(CHARGE//'.ELIM      .AFCK',IER)
          IF (ICINE.LT.0 .OR. IER.GT.0) THEN
            ICHCI = ICHCI + 1
            CALL GCNCO2(NEWNOM)
            CHAMNO(10:16) = NEWNOM(2:8)
            CALL CORICH('E',CHAMNO,ICHAR,IBID)
            ZK24(ILCHNO-1+ICHCI) = CHAMNO
            IF (ICINE.LT.0) THEN
              CALL CALVCI(CHAMNO,NUMEDD,1,CHARGE,INST,'V')
            ELSE
              CALL CALVCI(CHAMNO,NUMEDD,1,CHARGE//'.ELIM',INST,'V')
            ENDIF
            CALL JEVEUO(CHAMNO//'.DLCI','L',JDLCI)
C           --- COMBINAISON DES DLCI (OBJET CONTENANT DES 0 OU DES 1),
C           --- LES 1 ETANT POUR LES DDL CONTRAINT
C           --- LE RESTE DE L OBJECT VCI2 EST CREE PAR ASCOVA
            DO 30 IEQ=1,NEQ
C             -- ON REGARDE SI UN DDL N'EST PAS ELIMINE PLUSIEURS FOIS:
              IF (ZI(JDLCI2-1+IEQ).GT.0 .AND. ZI(JDLCI-1+IEQ).GT.0)
     &            IEQMUL=IEQ

              ZI(JDLCI2-1+IEQ)=MAX(ZI(JDLCI2-1+IEQ),ZI(JDLCI-1+IEQ))
   30       CONTINUE
          END IF
   20   CONTINUE
        CALL JEDETR(CHAMNO//'.DLCI')
      END IF

C     -- SI UN DDL A ETE ELIMINE PLUSIEURS FOIS :
      IF (IEQMUL.GT.0) THEN
        CALL RGNDAS(NUMEDD,IEQMUL,NOMNO,NOMCMP,TYDDL,
     &              LIGREL,INFOBL)
        CALL ASSERT(TYDDL.EQ.'A')
        VALK(1)=NOMNO
        VALK(2)=NOMCMP
        CALL U2MESK('A','CALCULEL3_37',2,VALK)
      ENDIF



C     -- ON COMBINE LES CHAMPS CALCULES :
      CALL ASCOVA('D',VACHCI,FOMULT,'INST',INST,'R',VCI2)

C     --SI ON A PAS DE CHARGE CINEMATIQUE, IL FAUT QUAND MEME
C        FAIRE LE MENAGE
      IF (NCHCI.EQ.0) CALL DETRSD('CHAMP_GD',CHAMNO(1:19))
      CALL JEDETR(CHARCI)

      CALL JEDEMA()
      END
