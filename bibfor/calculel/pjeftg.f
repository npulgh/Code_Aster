      SUBROUTINE PJEFTG(IGEOM,GEOMI,NOMAI,MOTFAC,IOCC)
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C BUT : TRANSFORMER LA GEOMETRIE DES NOEUDS DU MAILLAGE_2 AVANT LA
C       LA PROJECTION (MOT CLE TRANSF_GEOM_2).
C       CELA PERMET PAR EXEMPLE DE PROJETER :
C       - UN MAILLLAGE SUR UN AUTRE MAILLAGE HOMOTHETIQUE
C       - UN MAILLAGE 2D SUR UN MAILLAGE 3D "ECRASE" DANS UN PLAN
C         (2D AXIS -> 3D AXIS)
C
C OUT : GEOMI (K24) : NOM DE L'OBJET CONTENANT LA GEOMETRIE TRANSFORMEE
C       DES NOEUDS DU MAILLAGE_[1|2]
C       SI PAS DE GEOMETRIE TRANSFORMEE GEOMI=' '
C
C ----------------------------------------------------------------------
      IMPLICIT   NONE
C
C 0.1. ==> ARGUMENTS
C
      INCLUDE 'jeveux.h'
      INTEGER       IGEOM
      CHARACTER*8   NOMAI
      CHARACTER*24  GEOMI
      CHARACTER*(*) MOTFAC
      INTEGER       IOCC
C
C 0.2. ==> COMMUNS


C
C 0.3. ==> VARIABLES LOCALES
C

      CHARACTER*8 LFONC(3),LPARX(3)
      CHARACTER*8 KBID
      INTEGER N1,NBNOI,IFONC
      INTEGER NFONC,JGEOMI,INOI,IER

      REAL*8  VX(3)
      INTEGER      IARG
C----------------------------------------------------------------------
C DEB ------------------------------------------------------------------
      CALL JEMARQ()

      CALL ASSERT( (IGEOM.EQ.1).OR.(IGEOM.EQ.2) )

C     PRISE EN COMPTE DU MOT-CLE TRANSF_GEOM_[1|2] : CALCUL DE GEOMI
C     --------------------------------------------------------------
      IF ( IGEOM .EQ. 1) THEN
         CALL GETVID(MOTFAC,'TRANSF_GEOM_1',IOCC,IARG,3,LFONC,NFONC)
      ELSE
         CALL GETVID(MOTFAC,'TRANSF_GEOM_2',IOCC,IARG,3,LFONC,NFONC)
      ENDIF
      CALL ASSERT(NFONC.GE.0)
      IF (NFONC.GT.0) THEN
         CALL ASSERT(NFONC.EQ.2 .OR. NFONC.EQ.3)
         IF (NFONC.EQ.2) LFONC(3)='&FOZERO'
         IF ( IGEOM .EQ. 1 ) THEN
            GEOMI='&&PJEFTG.GEOM1'
         ELSE
            GEOMI='&&PJEFTG.GEOM2'
         ENDIF
         CALL JEDETR(GEOMI)
         CALL JEDUPO(NOMAI//'.COORDO    .VALE', 'V', GEOMI, .FALSE.)
         CALL JELIRA(GEOMI,'LONMAX',N1,KBID)
         CALL JEVEUO(GEOMI,'E',JGEOMI)
         NBNOI=N1/3
         CALL ASSERT(N1.EQ.NBNOI*3)
         LPARX(1)='X'
         LPARX(2)='Y'
         LPARX(3)='Z'
         DO 1, INOI=1,NBNOI
           DO 2, IFONC=1,3
             CALL FOINTE('F',LFONC(IFONC),3,LPARX,
     &           ZR(JGEOMI-1+3*(INOI-1)+1),VX(IFONC),IER)
             CALL ASSERT(IER.EQ.0)
2          CONTINUE
           ZR(JGEOMI-1+3*(INOI-1)+1)=VX(1)
           ZR(JGEOMI-1+3*(INOI-1)+2)=VX(2)
           ZR(JGEOMI-1+3*(INOI-1)+3)=VX(3)
1        CONTINUE
      ELSE
         GEOMI = ' '
      ENDIF

      CALL JEDEMA()
      END
