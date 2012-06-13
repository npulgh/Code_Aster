      SUBROUTINE NXRECH (MODELE,MATE,CARELE,CHARGE,
     &                   INFOCH,NUMEDD,TIME,LONCH,COMPOR,
     &                   VTEMPM,VTEMPP,VTEMPR,VTEMP,VHYDR,VHYDRP,
     &                   TMPCHI,TMPCHF,VEC2ND,CNVABT,CNRESI,RHO,
     &                   ITERHO,PARMER,PARMEI)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C RESPONSABLE                            DURAND C.DURAND
C TOLE CRP_21
C
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      INTEGER      PARMEI(2),LONCH
      REAL*8       PARMER(2),RHO
      CHARACTER*24 MODELE,MATE,CARELE,CHARGE,INFOCH,NUMEDD,TIME
      CHARACTER*24 VTEMP,VTEMPM,VTEMPP,VTEMPR,CNVABT,CNRESI,VEC2ND
      CHARACTER*24 VHYDR,VHYDRP,COMPOR,TMPCHI,TMPCHF
C
C ----------------------------------------------------------------------
C
C COMMANDE THER_NON_LINE : RECHERCHE LINEAIRE
C DANS LA DIRECTION DONNEE PAR NEWTON (ON CHERCHE RHO).
C
C
C
C
      INTEGER      I
      INTEGER      JTEMPM,JTEMPP,JTEMPR,J2ND,JVARE,JBTLA
      REAL*8       RHO0,RHOT,F0,F1,RHOMIN,RHOMAX
      REAL*8       RHOF,FFINAL
      REAL*8       R8PREM,TESTM,R8BID
      CHARACTER*24 VEBTLA,VERESI,VARESI,BIDON,VABTLA
      CHARACTER*1  TYPRES
      INTEGER      ITRMAX,K,ITERHO
      PARAMETER (RHOMIN = -2.D0, RHOMAX = 2.D0)
      DATA TYPRES        /'R'/
      DATA BIDON         /'&&FOMULT.BIDON'/
      DATA VERESI        /'&&VERESI           .RELR'/
      DATA VEBTLA        /'&&VETBTL           .RELR'/
C
C-----------------------------------------------------------------------
C
      CALL JEMARQ()
      VARESI = '&&VARESI'
C
C --- RECUPERATION D'ADRESSES JEVEUX
C
      CALL JEVEUO (VTEMPM(1:19)//'.VALE','E',JTEMPM )
      CALL JEVEUO (VTEMPP(1:19)//'.VALE','E',JTEMPP )
      CALL JEVEUO (VTEMPR(1:19)//'.VALE','E',JTEMPR )
      CALL JEVEUO (VEC2ND(1:19)//'.VALE','L',J2ND)
      CALL JEVEUO (CNRESI(1:19)//'.VALE','L',JVARE)
      CALL JEVEUO (CNVABT(1:19)//'.VALE','L',JBTLA)
C
C --- RECHERCHE LINEAIRE (CALCUL DE RHO) SUR L'INCREMENT VTEMPP
C
      F0 = 0.D0
      DO 330 I = 1,LONCH
         F0 = F0 + ZR(JTEMPP+I-1)*( ZR(J2ND+I-1) -
     &                              ZR(JVARE+I-1) - ZR(JBTLA+I-1) )
  330 CONTINUE
C
      RHO0 = 0.D0
      RHO  = 1.D0
      ITRMAX = PARMEI(2)+1
      DO 20 ITERHO=1,ITRMAX
         DO 345 I = 1,LONCH
            ZR(JTEMPR+I-1) = ZR(JTEMPM+I-1) + RHO * ZR(JTEMPP+I-1)
  345    CONTINUE
C
C --- VECTEURS RESIDUS ELEMENTAIRES - CALCUL ET ASSEMBLAGE
C
        CALL VERSTP (MODELE,CHARGE,INFOCH,CARELE,MATE,TIME,COMPOR,
     &               VTEMP,VTEMPR,VHYDR,VHYDRP,TMPCHI,TMPCHF,VERESI)
        CALL ASASVE (VERESI,NUMEDD,TYPRES,VARESI)
        CALL ASCOVA('D',VARESI,BIDON,'INST',R8BID,TYPRES,CNRESI)
        CALL JEVEUO (CNRESI(1:19)//'.VALE','L',JVARE)
C
C --- BT LAMBDA - CALCUL ET ASSEMBLAGE
C
        CALL VETHBT (MODELE,CHARGE,INFOCH,CARELE,MATE,VTEMPR,VEBTLA)
        CALL ASASVE (VEBTLA,NUMEDD,TYPRES,VABTLA)
        CALL ASCOVA('D',VABTLA,BIDON,'INST',R8BID,TYPRES,CNVABT)
        CALL JEVEUO (CNVABT(1:19)//'.VALE','L',JBTLA)
C
        F1 = 0.D0
        DO 360 I = 1,LONCH
          F1 = F1 + ZR(JTEMPP+I-1) * ( ZR(J2ND+I-1) -
     &                                 ZR(JVARE+I-1) - ZR(JBTLA+I-1) )
  360   CONTINUE
        TESTM = 0.D0
        DO 100 K = 1,LONCH
          TESTM = MAX( TESTM,
     &                 ABS(ZR(J2ND+K-1)-ZR(JVARE+K-1)-ZR(JBTLA+K-1)))
 100    CONTINUE
        IF (TESTM.LT.PARMER(2)) GO TO 9999

        IF(ITERHO.EQ.1)THEN
         FFINAL = F1
         RHOF = 1.D0
        ENDIF
        IF(ABS(F1).LT.ABS(FFINAL))THEN
         FFINAL=F1
         RHOF=RHO
        ENDIF
        RHOT=RHO
        IF (ABS(F1-F0).GT.R8PREM()) THEN
          RHO  = -(F0*RHOT-F1*RHO0)/(F1-F0)
          IF (RHO.LT.RHOMIN) RHO = RHOMIN
          IF (RHO.GT.RHOMAX) RHO = RHOMAX
          IF (ABS(RHO-RHOT).LT.1.D-08) GOTO 40
        ELSE
          GOTO 40
        END IF
         RHO0= RHOT
         F0  = F1
 20     CONTINUE
 40     CONTINUE
        RHO=RHOF
        F1=FFINAL
C
C-----------------------------------------------------------------------
 9999 CONTINUE
      ITERHO = ITERHO - 1
      CALL JEDEMA()
      END
