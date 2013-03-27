      SUBROUTINE CAPRES ( CHAR, LIGRMO, NOMA, NDIM, FONREE)
      IMPLICIT   NONE
      INCLUDE 'jeveux.h'
      INTEGER           NDIM
      CHARACTER*4       FONREE
      CHARACTER*8       CHAR, NOMA
      CHARACTER*(*)     LIGRMO
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 26/03/2013   AUTEUR CUVILLIE M.CUVILLIEZ 
C ======================================================================
C COPYRIGHT (C) 1991 - 2013  EDF R&D                  WWW.CODE-ASTER.ORG
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
C
C BUT : STOCKAGE DES PRESSIONS DANS UNE CARTE ALLOUEE SUR LE
C       LIGREL DU MODELE (Y COMPRIS THM)
C
C ARGUMENTS D'ENTREE:
C      CHAR   : NOM UTILISATEUR DU RESULTAT DE CHARGE
C      LIGRMO : NOM DU LIGREL DE MODELE
C      NOMA   : NOM DU MAILLAGE
C      NDIM   : DIMENSION DU PROBLEME (2D OU 3D)
C      FONREE : FONC OU REEL
C-----------------------------------------------------------------------
      INTEGER       IBID, NPRES, NCMP, JVALV, JNCMP, IOCC, NP, NC, IER,
     &              NBTOU, NBMA, JMA ,NFISS,NFISMX
      PARAMETER    (NFISMX=100)
      CHARACTER*8   K8B, TYPMCL(2),FISS(NFISMX)
      CHARACTER*16  MOTCLF, MOTCLE(2)
      CHARACTER*19  CARTE
      CHARACTER*24  MESMAI,LISMAI
      INTEGER      IARG
C-----------------------------------------------------------------------
      CALL JEMARQ()
C
      MOTCLF = 'PRES_REP'
      CALL GETFAC ( MOTCLF, NPRES )
C
      CARTE = CHAR//'.CHME.PRESS'
C
      IF (FONREE.EQ.'REEL') THEN
         CALL ALCART ( 'G', CARTE, NOMA, 'PRES_R')
      ELSEIF (FONREE.EQ.'FONC') THEN
         CALL ALCART ( 'G', CARTE, NOMA, 'PRES_F')
      ELSE
         CALL U2MESK('F','MODELISA2_37',1,FONREE)
      END IF
C
      CALL JEVEUO ( CARTE//'.NCMP', 'E', JNCMP )
      CALL JEVEUO ( CARTE//'.VALV', 'E', JVALV )
C
C --- STOCKAGE DE FORCES NULLES SUR TOUT LE MAILLAGE
C
      NCMP = 2
      ZK8(JNCMP)   = 'PRES'
      ZK8(JNCMP+1) = 'CISA'

      IF (FONREE.EQ.'REEL') THEN
         ZR(JVALV)   = 0.D0
         ZR(JVALV+1) = 0.D0
      ELSE
         ZK8(JVALV)   = '&FOZERO'
         ZK8(JVALV+1) = '&FOZERO'
      END IF
      CALL NOCART (CARTE,1,' ','NOM',0,' ',0,LIGRMO,NCMP)
C
      MESMAI = '&&CAPRES.MES_MAILLES'
      LISMAI = '&&CAPRES.NUM_MAILLES'
      MOTCLE(1) = 'GROUP_MA'
      MOTCLE(2) = 'MAILLE'
      TYPMCL(1) = 'GROUP_MA'
      TYPMCL(2) = 'MAILLE'
C
C --- STOCKAGE DANS LA CARTE
C
      DO 10 IOCC = 1, NPRES
C
         IF (FONREE.EQ.'REEL') THEN
            CALL GETVR8 (MOTCLF, 'PRES'   , IOCC,IARG,1,ZR(JVALV)  ,NP)
            CALL GETVR8 (MOTCLF, 'CISA_2D', IOCC,IARG,1,ZR(JVALV+1),NC)
         ELSE
            CALL GETVID (MOTCLF, 'PRES'   , IOCC,IARG,1,ZK8(JVALV)  ,NP)
            CALL GETVID (MOTCLF, 'CISA_2D', IOCC,IARG,1,ZK8(JVALV+1),NC)
         ENDIF
         IF (NC.NE.0.AND.NDIM.EQ.3) CALL U2MESS('F','MODELISA9_94')
C
         CALL GETVTX ( MOTCLF, 'TOUT', IOCC,IARG, 1, K8B, NBTOU )
         CALL GETVID ( MOTCLF, 'FISSURE',IOCC ,IARG, 0, K8B, NFISS )

         IF ( NBTOU .NE. 0 ) THEN
C
            CALL NOCART(CARTE, 1, ' ', 'NOM', 0, ' ', 0,LIGRMO, NCMP)

         ELSEIF ( NFISS . NE. 0 ) THEN

C           PAS DE CISA_2D SUR LES L�VRES DES FISSURES X-FEM
            IF (NC.NE.0) CALL U2MESS('F','XFEM_14')

            NFISS = -NFISS
            CALL GETVID(MOTCLF,'FISSURE',IOCC,IARG,NFISS,FISS , IBID )
C           VERIFICATION DE LA COHERENCE ENTRE LES FISSURES ET LE MODELE
            CALL XVELFM(NFISS,FISS,LIGRMO(1:8))
C           RECUPERATION DES MAILLES PRINCIPALES X-FEM FISSUREES
            CALL XTMAFI(NOMA,NDIM,FISS,NFISS,LISMAI,MESMAI,NBMA)
            CALL JEVEUO ( MESMAI, 'L', JMA )
            CALL NOCART (CARTE,3,K8B,'NOM',NBMA,ZK8(JMA),IBID,' ',NCMP)
            CALL JEDETR ( MESMAI )
            CALL JEDETR ( LISMAI )

         ELSE

            CALL RELIEM(LIGRMO, NOMA, 'NO_MAILLE', MOTCLF, IOCC, 2,
     &                                  MOTCLE, TYPMCL, MESMAI, NBMA )
            IF (NBMA.EQ.0) GOTO 10
            CALL JEVEUO ( MESMAI, 'L', JMA )
            CALL VETYMA ( NOMA, ZK8(JMA),NBMA, K8B,0, MOTCLF,NDIM,IER)
            CALL NOCART (CARTE,3,K8B,'NOM',NBMA,ZK8(JMA),IBID,' ',NCMP)

            CALL JEDETR ( MESMAI )
         ENDIF
C
 10   CONTINUE

C-----------------------------------------------------------------------
      CALL JEDEMA()
      END
