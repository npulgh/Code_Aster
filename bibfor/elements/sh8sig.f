      SUBROUTINE SH8SIG(XETEMP,PARA,XIDEPP,DUSX,SIGMA)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C
C               ELEMENT SHB8
C
      IMPLICIT REAL*8 (A-H,O-Z)
      INCLUDE 'jeveux.h'
      INTEGER LAG,IRDC
      REAL*8 SIGMA(*),PARA(11)
      REAL*8 XE(24),DUSX(*),XIDEPP(*)
      REAL*8 XXG5(5),XCOQ(3,4),BKSIP(3,8,5),B(3,8)
      REAL*8 XCENT(3),PPP(3,3),PPPT(3,3)
      REAL*8 XL(3,4),XXX(3),YYY(3)
      REAL*8 CMATLO(6,6),RR2(3,3),LAMBDA
      REAL*8 DEPS(6),DUSDX(9),UE(3,8)
      REAL*8 DEPSLO(6),SIGLOC(6)
      REAL*8 RR12(3,3)
      REAL*8 XETEMP(*)
C      REAL*8 PXG5(5)
C
C
CCCCCCCCCCCCCC ENTREES CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C          ICLE=7    ON CALCULE LES CONTRAINTES
C    OPTION=SIEF_ELGA    ON CALCULE LES CONTRAINTES
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C INITIALISATIONS
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C INFOS:
C XE EST RANGE COMME CA:
C (XNOEUD1 YNOEUD1 ZNOEUD1, XNOEUD2 YNOEUD2 ZNOEUD2,...)
C DANS SHB8_TEST_NUM: ATTENTION A LA NUMEROTATION DES NOEUDS
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C      IF (NOMSHB.EQ.'SHB8') THEN
C
C ON DEFINI LES POINTS GAUSS ET LES POIDS
C
      XXG5(1) = -0.906179845938664D0
      XXG5(2) = -0.538469310105683D0
      XXG5(3) = 0.D0
      XXG5(4) = 0.538469310105683D0
      XXG5(5) = 0.906179845938664D0
C
C      PXG5(1) = 0.236926885056189D0
C      PXG5(2) = 0.478628670499366D0
C      PXG5(3) = 0.568888888888889D0
C      PXG5(4) = 0.478628670499366D0
C      PXG5(5) = 0.236926885056189D0
C
C -----------------------------------------------------
C ON VERIFIE QUE LA CONNECTIVITE DONNE UN REPERE DIRECT
C SI CE N EST PAS LE CAS ON PERMUTE LES NOEUDS
C -----------------------------------------------------
C
C     ON FAIT UNE COPIE DE XETEMP DANS XE
      DO 10 I = 1,24
         XE(I) = XETEMP(I)
   10 CONTINUE
C TYPE DE LOI DE COMPORTEMENT:
C     IRDC = 1 : SHB8 TYPE PLEXUS
C     IRDC = 2 : C.P.
C     IRDC = 3 : 3D COMPLETE
C***         IRDC = OUT(1)
      IRDC = NINT(PARA(5))
      CALL R8INIR(36,0.D0,CMATLO,1)
C
C UE: INCREMENT DE DEPLACEMENT NODAL, REPERE GLOBAL
C
C XE: DEBUT DU PAS
      DO 360 J = 1,8
         DO 350 I = 1,3
            UE(I,J) = XIDEPP((J-1)*3+I)
  350    CONTINUE
  360 CONTINUE
      LAG = NINT(PARA(6))
C ON DEFINIT CMATLO LOI MODIFIEE SHB8
C
      LAMBDA = PARA(1)*PARA(2)/ (1-PARA(2)*PARA(2))
      XMU = 0.5D0*PARA(1)/ (1+PARA(2))
      CMATLO(1,1) = LAMBDA + 2*XMU
      CMATLO(2,2) = LAMBDA + 2*XMU
      IF (IRDC.EQ.1) THEN
C COMPORTEMENT SHB8 PLEXUS
C         CMATLO(3,3) = PROPEL(1)
          CMATLO(3,3) = PARA(1)
      END IF
C
      IF (IRDC.EQ.2) THEN
C COMPORTEMENT C.P.
          CMATLO(3,3) = 0.D0
      END IF
C
      CMATLO(1,2) = LAMBDA
      CMATLO(2,1) = LAMBDA
      CMATLO(4,4) = XMU
      CMATLO(5,5) = XMU
      CMATLO(6,6) = XMU
C
      IF (IRDC.EQ.3) THEN
C COMPORTEMENT LOI TRIDIM MMC 3D
C
        XNU = PARA(2)
        XCOOEF = PARA(1)/ ((1+XNU)* (1-2*XNU))
        CMATLO(1,1) = (1-XNU)*XCOOEF
        CMATLO(2,2) = (1-XNU)*XCOOEF
        CMATLO(3,3) = (1-XNU)*XCOOEF
        CMATLO(1,2) = XNU*XCOOEF
        CMATLO(2,1) = XNU*XCOOEF
        CMATLO(1,3) = XNU*XCOOEF
        CMATLO(3,1) = XNU*XCOOEF
        CMATLO(2,3) = XNU*XCOOEF
        CMATLO(3,2) = XNU*XCOOEF
        CMATLO(4,4) = (1-2*XNU)*0.5D0*XCOOEF
        CMATLO(5,5) = (1-2*XNU)*0.5D0*XCOOEF
        CMATLO(6,6) = (1-2*XNU)*0.5D0*XCOOEF
      END IF
C
C CALCUL DE BKSIP(3,8,IP) DANS REPERE DE REFERENCE
C      BKSIP(1,*,IP) = VECTEUR BX AU POINT GAUSS IP
C      BKSIP(2,*,IP) = VECTEUR BY AU POINT GAUSS IP
C      BKSIP(3,*,IP) = VECTEUR BZ AU POINT GAUSS IP
C
      CALL SHBKSI(5,XXG5,BKSIP)
C
      DO 450 IP = 1,5
C
C DEFINITION DES 4 POINTS  COQUES
C
         ZETA = XXG5(IP)
         ZLAMB = 0.5D0* (1.D0-ZETA)
         DO 380 I = 1,4
            DO 370 J = 1,3
              XCOQ(J,I) = ZLAMB*XE((I-1)*3+J) +
     &              (1.D0-ZLAMB)*XE((I-1+4)*3+J)
  370       CONTINUE
  380    CONTINUE
C
C CALCUL DE PPP 3*3 PASSAGE DE GLOBAL A LOCAL,COQUE
C XCENT : COORD GLOBAL DU CENTRE DE L'ELEMENT
C
         CALL RLOSHB(XCOQ,XCENT,PPP,XL,XXX,YYY,RBID)
C
C CALCUL DE B : U_GLOBAL ---> EPS_GLOBAL
C
         CALL SHCALB(BKSIP(1,1,IP),XE,B,AJAC)
C
C CALCUL DE EPS DANS LE REPERE GLOBAL: 1 POUR DEFORMATIONS LINEAIRES
C                                     2 POUR TERMES CARRES EN PLUS
         DO 390 I = 1,6
            DEPS(I) = 0.D0
  390    CONTINUE
         IF (LAG.EQ.1) THEN
C ON AJOUTE LA PARTIE NON-LINEAIRE DE EPS
            CALL DSDX3D(2,B,UE,DEPS,DUSDX,8)
         ELSE
            CALL DSDX3D(1,B,UE,DEPS,DUSDX,8)
         END IF
C
C SORTIE DE DUSDX DANS PROPEL(1 A 9 * 5 PT DE GAUSS)
C POUR UTILISATION ULTERIEURE DANS Q8PKCN_SHB8
         DO 410 I = 1,3
            DO 400 J = 1,3
              PPPT(J,I) = PPP(I,J)
  400       CONTINUE
  410    CONTINUE
         RR12(1,1) = DUSDX(1)
         RR12(1,2) = DUSDX(2)
         RR12(1,3) = DUSDX(3)
         RR12(2,1) = DUSDX(4)
         RR12(2,2) = DUSDX(5)
         RR12(2,3) = DUSDX(6)
         RR12(3,1) = DUSDX(7)
         RR12(3,2) = DUSDX(8)
         RR12(3,3) = DUSDX(9)
         CALL MULMAT(3,3,3,PPPT,RR12,RR2)
         CALL MULMAT(3,3,3,RR2,PPP,RR12)
         DUSDX(1) = RR12(1,1)
         DUSDX(2) = RR12(1,2)
         DUSDX(3) = RR12(1,3)
         DUSDX(4) = RR12(2,1)
         DUSDX(5) = RR12(2,2)
         DUSDX(6) = RR12(2,3)
         DUSDX(7) = RR12(3,1)
         DUSDX(8) = RR12(3,2)
         DUSDX(9) = RR12(3,3)
         DO 420 I = 1,9
            DUSX(I+ (IP-1)*9) = DUSDX(I)
  420    CONTINUE
         DO 430 I = 1,6
           DEPSLO(I) = 0.D0
           SIGLOC(I) = 0.D0
  430    CONTINUE
         CALL CHRP3D(PPP,DEPS,DEPSLO,2)
C
C CALCUL DE SIGMA DANS LE REPERE LOCAL
C
         CALL MULMAT(6,6,1,CMATLO,DEPSLO,SIGLOC)
C
C CONTRAINTES ECRITES SOUS LA FORME:
C               [SIG] = [S_11, S_22, S_33, S_12, S_23, S_13]
         DO 440 I = 1,6
C ON LAISSE LES CONTRAINTES DANS LE REPERE LOCAL POUR LA PLASTICITE
            SIGMA((IP-1)*6+I) = SIGLOC(I)
  440    CONTINUE
  450 CONTINUE
C
      END
