      SUBROUTINE NMDOCN (MODELE, PARCRI, PARCON)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 15/05/2007   AUTEUR GENIAUT S.GENIAUT 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE MABBAS M.ABBAS

      IMPLICIT NONE
      REAL*8        PARCRI(11), PARCON(6)
      CHARACTER*24  MODELE

C ----------------------------------------------------------------------
C     SAISIE DES CRITERES DE CONVERGENCE : STAT_NON_LINE
C ----------------------------------------------------------------------
C
C      IN  MODELE : NOM DU MODELE
C      OUT PARCRI : PARAMETRES DES CRITERES DE CONVERGENCE
C                     1 : ITER_GLOB_MAXI
C                     2 : RESI_GLOB_RELA
C                     3 : RESI_GLOB_MAXI
C                     4 : ARRET (0=OUI, 1=NON)
C                     5 : ITER_GLOB_ELAS
C                     6 : RESI_REFE_RELA
C                    10 : INCO_GLOB_ABSO (LAGRANGIEN)
C                    11 : DIFF_GLOB_ABSO (LAGRANGIEN)
C      OUT PARCON : PARAMETRES DU CRITERE DE CONVERGENCE EN CONTRAINTE
C                   SI PARCRI(6)=RESI_CONT_RELA != R8VIDE()
C                     1 : SIGM_REFE
C                     2 : EPSI_REFE
C                     3 : FLUX_THER_REFE
C                     4 : FLUX_HYD1_REFE
C                     5 : FLUX_HYD2_REFE
C                     6 : VARI_REFE
C
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
C
      CHARACTER*32       JEXNUM , JEXNOM , JEXR8 , JEXATR
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------

      INTEGER      ITERAT, ITEPAS, IRET, IRE1, IRE2, IRE3, IBID
      REAL*8       RESI, R8VIDE,RBID
      CHARACTER*8  REP, K8BID
      COMPLEX*16   CBID
C-----------------------------------------------------------------------


      CALL JEMARQ()


C -- RECUPERATION DES CRITERES DE CONVERGENCE GLOBAUX

      CALL GETVIS('CONVERGENCE','ITER_GLOB_MAXI',1,1,1,ITERAT,IRET)
      PARCRI(1) = ITERAT

      CALL GETVIS('CONVERGENCE','ITER_GLOB_ELAS',1,1,1,ITERAT,IRET)
      PARCRI(5) = ITERAT

      CALL GETVR8('CONVERGENCE','RESI_GLOB_RELA',1,1,1,PARCRI(2),IRE1)
      IF (IRE1.LE.0) PARCRI(2) = R8VIDE()

      CALL GETVR8('CONVERGENCE','RESI_GLOB_MAXI',1,1,1,PARCRI(3),IRE2)
      IF (IRE2.LE.0) PARCRI(3) = R8VIDE()

      CALL GETVR8('CONVERGENCE','RESI_REFE_RELA',1,1,1,PARCRI(6),IRE3)
      IF (IRE3.LE.0) THEN
        PARCRI(6) = R8VIDE()
      ELSE
        CALL GETVR8('CONVERGENCE','SIGM_REFE',1,1,1,PARCON(1),IRET)
        IF (IRET.LE.0) PARCON(1)=R8VIDE()
        CALL GETVR8('CONVERGENCE','EPSI_REFE',1,1,1,PARCON(2),IRET)
        IF (IRET.LE.0) PARCON(2)=R8VIDE()
        CALL GETVR8('CONVERGENCE','FLUX_THER_REFE',1,1,1,PARCON(3),IRET)
        IF (IRET.LE.0) PARCON(3)=R8VIDE()
        CALL GETVR8('CONVERGENCE','FLUX_HYD1_REFE',1,1,1,PARCON(4),IRET)
        IF (IRET.LE.0) PARCON(4)=R8VIDE()
        CALL GETVR8('CONVERGENCE','FLUX_HYD2_REFE',1,1,1,PARCON(5),IRET)
        IF (IRET.LE.0) PARCON(5)=R8VIDE()
        CALL GETVR8('CONVERGENCE','VARI_REFE',1,1,1,PARCON(6),IRET)
        IF (IRET.LE.0) PARCON(6)=R8VIDE()
      ENDIF


      IF (IRE1.LE.0 .AND. IRE2.LE.0 .AND. IRE3.LE.0) PARCRI(2) = 1.D-6

      CALL GETVTX('CONVERGENCE','ARRET',1,1,1,REP,IRET)
      PARCRI(4) = 0
      IF ( IRET .GT. 0 ) THEN
        IF ( REP  .EQ. 'NON' ) PARCRI(4) = 1
      ENDIF

C    ALARMES RELATIVES A LA QUALITE DE LA CONVERGENCE

      IF (PARCRI(2).NE.R8VIDE()  .AND. PARCRI(2).GT.1.0001D-4)
     &  CALL U2MESS('A','ALGORITH7_21')

      CALL JEDEMA()
      END
