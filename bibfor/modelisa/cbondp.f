      SUBROUTINE CBONDP(CHAR,NOMA)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 18/12/2012   AUTEUR SELLENET N.SELLENET 
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
      IMPLICIT NONE
C     BUT: TRAITE LE MOT_CLE : ONDE_PLANE
C
C ARGUMENTS D'ENTREE:
C      CHAR   : NOM UTILISATEUR DE LA CHARGE
C      NOMA   : NOM DU MAILLAGE
C
C
      INCLUDE 'jeveux.h'

      REAL*8       DIR(4)
      CHARACTER*24 SIGNAL,MESMAI
      CHARACTER*8  CHAR,NOMA,TYPMCL(2),MODELE,K8B
      CHARACTER*2  TYPE
      INTEGER      NONDP, JMA, NBMA, IARG
      CHARACTER*16 MOTCLE(2)
      CHARACTER*19 CARTE, LIGRMO

C-----------------------------------------------------------------------
      INTEGER I ,JNCMP ,JVALV ,NBID ,NDIR ,NSI ,NTY

C-----------------------------------------------------------------------
      CALL JEMARQ()

      CALL GETVID(' ','MODELE',0,IARG,1,MODELE,JMA)
      LIGRMO = MODELE//'.MODELE'
C
C --- INFORMATIONS SUR L'ONDE PLANE
C
      CALL GETFAC('ONDE_PLANE', NONDP)

      IF (NONDP.EQ.0) GOTO 9999
      CALL GETVR8('ONDE_PLANE','DIRECTION',1,IARG,0,DIR,NDIR)
      NDIR = - NDIR
      CALL GETVR8 ('ONDE_PLANE','DIRECTION',1,IARG,NDIR,DIR,NBID)
      IF (NDIR.EQ.2) DIR(3) = 0.D0
      CALL GETVTX('ONDE_PLANE','TYPE_ONDE',1,IARG,1,TYPE,NTY)
      CALL GETVID('ONDE_PLANE','FONC_SIGNAL',1,IARG,1,SIGNAL,NSI)
C
C --- MAILLES CONSERNEES PAR L'ONDE PLANE
C
      MOTCLE(1) = 'GROUP_MA'
      MOTCLE(2) = 'MAILLE'
      TYPMCL(1) = 'GROUP_MA'
      TYPMCL(2) = 'MAILLE'

      MESMAI ='&&ONDPLA.MESMAI'

      CALL RELIEM(LIGRMO,NOMA,'NU_MAILLE','ONDE_PLANE',1,2,
     &            MOTCLE,TYPMCL,MESMAI,NBMA)

      IF (NBMA.EQ.0) GOTO 100

      CALL JEVEUO (MESMAI,'L',JMA)
C
C --- STOCKAGE DANS LA CARTE NEUT_K24
C
      CARTE=CHAR//'.CHME.ONDPL'
      CALL ALCART ('G', CARTE, NOMA, 'NEUT_K24')

      CALL JEVEUO ( CARTE//'.NCMP', 'E', JNCMP )
      CALL JEVEUO ( CARTE//'.VALV', 'E', JVALV )
C
C --- STOCKAGE DES VALEURS NULLES SUR TOUT LE MAILLAGE
C
      ZK8(JNCMP) = 'Z1'
      ZK24(JVALV) = '&FOZERO'
      CALL NOCART (CARTE,1,' ','NOM',0,' ',0,LIGRMO,1)

      ZK24(JVALV) = SIGNAL
      CALL NOCART (CARTE,3,K8B,'NUM',NBMA,K8B,ZI(JMA),' ',1)
C
C --- STOCKAGE DANS LA CARTE NEUT_R
C
      CARTE=CHAR//'.CHME.ONDPR'
      CALL ALCART ('G', CARTE, NOMA, 'NEUT_R')

      CALL JEVEUO ( CARTE//'.NCMP', 'E', JNCMP )
      CALL JEVEUO ( CARTE//'.VALV', 'E', JVALV )
C
C --- STOCKAGE DES VALEURS NULLES SUR TOUT LE MAILLAGE
C
      ZK8(JNCMP)   = 'X1'
      ZK8(JNCMP+1) = 'X2'
      ZK8(JNCMP+2) = 'X3'
      ZK8(JNCMP+3) = 'X4'
      CALL NOCART (CARTE,1,' ','NOM',0,' ',0,LIGRMO,4)

C --- REMPLISSAGE DE LA CARTE NEUT_R CORRESPONDANTE

      IF (NDIR.EQ.3) THEN
         IF (TYPE.EQ.'P ') THEN
            DIR(4) = 0.D0
         ELSEIF (TYPE.EQ.'SV') THEN
            DIR(4) = 1.D0
         ELSEIF (TYPE.EQ.'SH') THEN
            DIR(4) = 2.D0
         ELSEIF (TYPE.EQ.'S ') THEN
            CALL U2MESS('F','MODELISA3_61')
         ENDIF
      ELSE
         IF (TYPE.EQ.'P ') THEN
            DIR(4) = 0.D0
         ELSEIF (TYPE.EQ.'S ') THEN
            DIR(4) = 1.D0
         ELSEIF (TYPE.EQ.'SV'.OR.TYPE.EQ.'SH') THEN
            CALL U2MESS('F','MODELISA3_62')
         ENDIF
      ENDIF

      DO 10 I=1,4
        ZR(JVALV+I-1) = DIR(I)
  10    CONTINUE

      CALL NOCART (CARTE,3,K8B,'NUM',NBMA,K8B,ZI(JMA),' ',4)

 100  CONTINUE

      CALL JEDETR(MESMAI)

9999  CONTINUE
      CALL JEDEMA()
      END
