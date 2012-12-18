      SUBROUTINE XLENRI(NOMA  ,FISS  ,LISMAE,LISNOE)
C
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*8  FISS,NOMA
      CHARACTER*24 LISMAE,LISNOE
C
C ----------------------------------------------------------------------
C
C ROUTINE XFEM (CREATION DES SD)
C
C LECTURE DONNEES GROUP_MA_ENRI
C
C ----------------------------------------------------------------------
C
C
C OUT FISS   : NOM DE LA SD FISS_XFEM
C                 FISS//'.GROUP_MA_ENRI'
C                 FISS//'.GROUP_NO_ENRI'
C IN  NOMA   : NOM DU MAILLAGE
C OUT LISMAE : NOM DE LA LISTE DES MAILLES ENRICHIES
C OUT LISNOE : NOM DE LA LISTE DES NOEUDS ENRICHIS
C
C
C
C
      INTEGER      NBMAE,NBNOE,N,IER,JMAE,JNOE,I
      CHARACTER*8  K8B
      INTEGER      IARG
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      K8B=' '
C
C     RECUPERATION DU MOT-CLE FACULTATIF GROUP_MA_ENRI
      CALL GETVEM(NOMA,'GROUP_MA',' ','GROUP_MA_ENRI',1,IARG,0,K8B,N)

      IF (N.EQ.0) THEN

C       GROUP_MA_ENRI N'EST PAS RENSEIGNE : ON PREND TOUT LE MAILLAGE

        CALL DISMOI('F','NB_MA_MAILLA',NOMA,'MAILLAGE',NBMAE,K8B,IER)
        CALL DISMOI('F','NB_NO_MAILLA',NOMA,'MAILLAGE',NBNOE,K8B,IER)

        CALL WKVECT(LISMAE,'V V I  ',NBMAE,JMAE)
        CALL WKVECT(LISNOE,'V V I  ',NBNOE,JNOE)

        DO 10 I=1,NBMAE
          ZI(JMAE-1+I)=I
 10     CONTINUE

        DO 20 I=1,NBNOE
          ZI(JNOE-1+I)=I
 20     CONTINUE

      ELSE

C       GROUP_MA_ENRI EST RENSEIGNE

        CALL RELIEM(' ',NOMA,'NU_MAILLE',' ',1,1,
     &              'GROUP_MA_ENRI','GROUP_MA',LISMAE,NBMAE)

        CALL RELIEM(' ',NOMA,'NU_NOEUD',' ',1,1,
     &              'GROUP_MA_ENRI','GROUP_MA',LISNOE,NBNOE)

      ENDIF

C     ENREGISTREMENT DANS LA BASE GLOBALE
      CALL JEDUPO(LISMAE,'G',FISS(1:8)//'.GROUP_MA_ENRI',.FALSE.)
      CALL JEDUPO(LISNOE,'G',FISS(1:8)//'.GROUP_NO_ENRI',.FALSE.)
C
      CALL JEDEMA()
      END
