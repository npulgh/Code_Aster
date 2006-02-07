      SUBROUTINE NBNOCO (CHAR,MOTFAC,NOMA,MOTCLE,IREAD,INDQUA,JTRAV,
     &                   IWRITE,JSUMA,JSUNO,JNOQUA)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 06/02/2006   AUTEUR MABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2004  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT      NONE
      CHARACTER*8   CHAR
      CHARACTER*16  MOTFAC
      CHARACTER*8   NOMA
      CHARACTER*(*) MOTCLE
      INTEGER       IREAD
      INTEGER       INDQUA
      INTEGER       JTRAV
      INTEGER       JSUMA
      INTEGER       JSUNO
      INTEGER       JNOQUA     
      INTEGER       IWRITE      
C
C ----------------------------------------------------------------------
C ROUTINE APPELEE PAR : NBSUCO
C ----------------------------------------------------------------------
C
C DETERMINATION DU NOMBRE DE
C MAILLES ET DE NOEUDS DE CONTACT POUR LA SURFACE IREAD
C REMPLISSAGE DES POINTEURS ASSOCIES JSUMA,JSNUO ET JNOQUA
C
C IN  CHAR   : NOM UTILISATEUR DU CONCEPT DE CHARGE
C IN  MOTFAC : MOT-CLE FACTEUR (VALANT 'CONTACT')
C IN  NOMA   : NOM DU MAILLAGE
C IN  MOTCLE : MOT-CLE (GROUP_MA_MAIT...)
C IN  IREAD  : INDICE POUR LIRE LES DONNEES DANS AFFE_CHAR_MECA
C IN  INDQUA : VAUT 1 LORSQUE L'ON DOIT IGNORER LES NOEUDS MILIEUX DANS
C              NBNOEL (PENALISATION SUR LE CONTACT OU METHODE CONTINUE)
C IN  JTRAV  : POINTEUR VERS VECTEUR DE TRAVAIL 'BIDON'
C I/O JSUMA  : POINTEUR SUR LA ZONE DES MAILLES
C I/O JSUNO  : POINTEUR SUR LA ZONE DES NOEUDS
C I/O JNOQUA : POINTEUR SUR LA ZONE DES NOEUDS QUADRATIQUES
C I/O IWRITE : INDICE POUR ECRIRE LES DONNEES DANS LA SD DEFICONT
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
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
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      CHARACTER*8  TYPENT,K8BID
      CHARACTER*16 PROJ
      INTEGER      NBENT,NB,NBMA,NBNO,NBNOQU,INPROJ,NOC
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()

      CALL GETVTX (MOTFAC,'PROJECTION',IREAD,1,1,PROJ,NOC)   
      IF (PROJ.EQ.'QUADRATIQUE') THEN
         INPROJ = 2
      ELSE
         INPROJ = 1
      ENDIF

      IF (MOTCLE(1:6).EQ.'MAILLE') THEN
         TYPENT = 'MAILLE'    
      ELSE IF (MOTCLE(1:8).EQ.'GROUP_MA') THEN
         TYPENT = 'GROUP_MA'    
      ELSE
         CALL UTMESS ('F','NBNOCO',
     +                'MOT CLE INCONNU (NI MAILLE, NI GROUP_MA')
      ENDIF

      CALL GETVEM(NOMA,TYPENT,MOTFAC,MOTCLE,
     +            IREAD,1,0,K8BID,NBENT)

      IF (NBENT.NE.0) THEN
          NBENT   = -NBENT        
          IWRITE  = IWRITE + 1
          CALL GETVEM(NOMA,TYPENT,MOTFAC,MOTCLE,
     +           IREAD,1,NBENT,ZK8(JTRAV),NB)
          IF (TYPENT.EQ.'MAILLE') THEN
            CALL NBNOEL(CHAR,NOMA,TYPENT,0,ZK8(JTRAV),INDQUA,
     +                INPROJ,NB,NBNO,NBNOQU)
            NBMA = NB
          ELSE
            CALL NBNOEL(CHAR,NOMA,TYPENT,NB,ZK8(JTRAV),INDQUA,
     +                INPROJ,NBMA,NBNO,NBNOQU)
          ENDIF

          ZI(JSUMA  + IWRITE) = ZI(JSUMA  + IWRITE-1) + NBMA
          ZI(JSUNO  + IWRITE) = ZI(JSUNO  + IWRITE-1) + NBNO
          ZI(JNOQUA + IWRITE) = ZI(JNOQUA + IWRITE-1) + NBNOQU

      ENDIF

C
C ----------------------------------------------------------------------
C
      CALL JEDEMA()
      END
