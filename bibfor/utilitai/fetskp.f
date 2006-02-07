      SUBROUTINE FETSKP()

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 07/02/2006   AUTEUR CIBHHLV L.VIVAN 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRP_4
C TOLE CRP_20
C-----------------------------------------------------------------------
C    - FONCTION REALISEE: 
C       - CREATION DU GRAPHE D'ENTREE DU PARTITIONNEUR
C       - GERE LES POIDS SUR LES MAILLES
C       - GERE LE GROUPAGE DES MAILLES
C       - APPEL A METIS OU EXECUTION DE SCOTCH
C       - CREATION DE NOUVEAUX GROUPES DE MAILLES
C       - VERIFICATION DE LA CONNEXITE DES SOUS-DOMAINES
C----------------------------------------------------------------------
C RESPONSABLE ASSIRE A.ASSIRE

C CORPS DU PROGRAMME
      IMPLICIT NONE

C --------- DEBUT DECLARATIONS NORMALISEES JEVEUX --------------------
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
      INTEGER*4          ZI4
      COMMON  / I4VAJE / ZI4(1)
C --------- FIN DECLARATIONS NORMALISEES JEVEUX --------------------

C DECLARATION VARIABLES LOCALES
      INTEGER       NBMAMA,IDCO,TEMP,SDB,NBMATO,MAIL,RENUM2,NBMA,NOMSDM,
     &              MASD,NBMASD,IDMASD,ID,ID1,ISD,RENUM1,ERR,IULM3,CO,
     &              RENUM,NBRE,NBMABO,MAIL2,VELO,EDLO,POIDS,NUMSDM,NMAP,
     &              I,J,IMA,NBBORD,LREP,IULM1,ULNUME,IOCC,NOCC,
     &              IFM,NIV,NBLIEN,NBPART,RENUM3,IDMA,IULM2,MABORD,VAL
      REAL*8        TMPS(6)
      CHARACTER*8   MA,K8BID,GRPEMA,KTMP,NOM,MOD,SDBORD,FATAL,
     &              VERIF,KTMP2,METH,BORD,KTMP3,KTMP4
      CHARACTER*32  JEXNUM
      CHARACTER*80  JNOM(4)
      CHARACTER*128 REP
      
C CORPS DU PROGRAMME
      CALL JEMARQ()
      CALL INFNIV(IFM,NIV)
      

C ********************************************************************
C                       CREATION DU GRAPHE 
      
C ------- ON RECUPERE LES DONNEES DU MAILLAGE OU DU MODELE 

      CALL GETVID(' ','MAILLAGE',0,1,1,MA,ERR)
      IF (ERR .EQ. 0 ) THEN
        CALL UTMESS('F','FETSKP',' ERREUR DANS LA  RECUPERATION  '//
     &                 'DU MAILLAGE!') 
      ENDIF    
      CALL DISMOI('F','NB_MA_MAILLA',MA,'MAILLAGE',NBMATO,K8BID,ERR)
      IF (ERR .NE. 0 ) THEN
        CALL UTMESS('F','FETSKP',' ERREUR DANS LA  RECUPERATION  '//
     &                 'DU NOMBRE DE MAILLES !') 
      ENDIF    
      CALL WKVECT('&&FETSKP.RENUM1','V V I',NBMATO,RENUM1)
      CALL GETVID(' ','MODELE' ,0,1,1,MOD,ERR)
      IF ( ERR .EQ. 0 ) THEN
        WRITE(IFM,*)' -- AUCUN MODELE PRIS EN COMPTE'
        CALL WKVECT('&&FETSKP.RENUM','V V I',NBMATO,RENUM)
        DO 90 IMA=1,NBMATO
          ZI(RENUM-1+IMA)=IMA
          ZI(RENUM1-1+IMA)=IMA
 90     CONTINUE
      ELSE      
        WRITE(IFM,*)' -- PRISE EN COMPTE DU MODELE :',MOD
        NBMATO=0 
        CALL JELIRA(MOD//'.MODELE    .LIEL','NMAXOC',NOCC,K8BID)
        DO 94 IOCC=1,NOCC
          CALL JELIRA(JEXNUM(MOD//'.MODELE    .LIEL',IOCC),'LONMAX'
     &                  ,NBMA,K8BID)
          NBMATO=NBMATO+NBMA-1
 94     CONTINUE 
        CALL WKVECT('&&FETSKP.RENUM','V V I',NBMATO,RENUM)
        ID=1
        DO 93 IOCC=1,NOCC
          CALL JELIRA(JEXNUM(MOD//'.MODELE    .LIEL',IOCC),'LONMAX'
     &                  ,NBMA,K8BID)
          CALL JEVEUO(JEXNUM(MOD//'.MODELE    .LIEL',IOCC),'L',IDMA)
          DO 91 IMA=1,NBMA-1
            ZI(RENUM-1+ID)=ZI(IDMA-1+IMA)
            ZI(RENUM1-1+ZI(IDMA-1+IMA))=ID
            ID=ID+1
 91       CONTINUE   
 93     CONTINUE 
      ENDIF
      
C ------- CREATION DE LA CONNECTIVITE DES MAILLES

      CALL CREACO(NBMATO,MA,BORD,NBBORD,NBLIEN,NBMABO)

C ------ ON RECUPERE LES TABLEAUX CONSTRUITS DANS CREACO

      CALL JEVEUO('&&FETSKP.RENUM2','L',RENUM2)
      CALL JEVEUO('&&FETSKP.RENUM3','L',RENUM3)
      CALL JEVEUO('&&FETSKP.CO'    ,'L',CO)
      CALL JEVEUO('&&FETSKP.IDCO'  ,'L',IDCO)
      CALL JEVEUO('&&FETSKP.NBMAMA','L',NBMAMA)
      CALL JEVEUO('&&FETSKP.MABORD','E',MABORD)

C ------- ON RECUPERE LE NBRE DE SD ET LE PARTITONNEUR 
 
      CALL GETVIS(' ','NB_PART',0,1,1,NBPART,ERR)
      CALL GETVTX(' ','METHODE',0,1,1,METH,ERR)

C -------  UTILISATION DE CONTRAINTES

      CALL WKVECT('&&FETSKP.VELO','V V S',NBMATO,VELO)
      CALL WKVECT('&&FETSKP.EDLO','V V S',NBLIEN,EDLO)
      DO 114 IMA=1,NBMATO
        ZI4(VELO-1+IMA)=1
 114  CONTINUE  
      DO 115 I=1,NBLIEN
        ZI4(EDLO-1+I)=1
 115  CONTINUE

      CALL GETFAC('GROUPAGE',NOCC)
      DO 116 IOCC=1,NOCC
        CALL GETVID('GROUPAGE','GROUP_MA',IOCC,1,1,GRPEMA,ERR)
        CALL JELIRA(MA//'.GROUPEMA','NMAXOC',NBRE,K8BID)
        NBMA=0
        DO 118 J=1,NBRE
          CALL JENUNO(JEXNUM(MA//'.GROUPEMA',J),NOM)
          IF (NOM .EQ. GRPEMA) THEN
            CALL JELIRA(JEXNUM(MA//'.GROUPEMA',J),'LONMAX',NBMA,K8BID)
            CALL JEVEUO(JEXNUM(MA//'.GROUPEMA',J),'L',IDMA)
          ENDIF   
 118    CONTINUE 
        IF ( NBMA .EQ. 0) THEN
          CALL UTMESS('F','FETSKP',' GRUOPAGE : 
     &                                   GROUPE_MA NON PRESENT !')   
        ENDIF    
        WRITE(IFM,*)'  - GROUPAGE  :',GRPEMA
        WRITE(IFM,*)' '
        DO 204 IMA=1,NBMA-1
          MAIL=ZI(RENUM3-1+ZI(RENUM1-1+ZI(IDMA-1+IMA)))
          DO 212 I=IMA+1,NBMA
            MAIL2=ZI(RENUM3-1+ZI(RENUM1-1+ZI(IDMA-1+I)))
            DO 205 J=ZI4(IDCO-1+MAIL),ZI4(IDCO-1+MAIL+1)-1
              IF (ZI4(CO-1+J) .EQ. MAIL2) ZI4(EDLO-1+J)=NBMATO+1
 205        CONTINUE
            DO 220 J=ZI4(IDCO-1+MAIL2),ZI4(IDCO-1+MAIL2+1)-1
              IF (ZI4(CO-1+J) .EQ. MAIL) ZI4(EDLO-1+J)=NBMATO+1
 220        CONTINUE
 212      CONTINUE
 204    CONTINUE 
 116  CONTINUE     

      CALL GETFAC('POIDS_MAILLES',NOCC)
      DO 117 IOCC=1,NOCC
        CALL GETVID('POIDS_MAILLES','GROUP_MA',IOCC,1,1,GRPEMA,ERR)
        CALL JELIRA(MA//'.GROUPEMA','NMAXOC',NBRE,K8BID)
        NBMA=0
        DO 207 J=1,NBRE
          CALL JENUNO(JEXNUM(MA//'.GROUPEMA',J),NOM)
          IF (NOM .EQ. GRPEMA) THEN
            CALL JELIRA(JEXNUM(MA//'.GROUPEMA',J),'LONMAX',NBMA,K8BID)
            CALL JEVEUO(JEXNUM(MA//'.GROUPEMA',J),'L',IDMA)
          ENDIF   
 207    CONTINUE 
        IF ( NBMA .EQ. 0) THEN
          CALL UTMESS('F','FETSKP',' GRUOPAGE : 
     &                                   GROUPE_MA NON PRESENT !')   
        ENDIF    
        CALL GETVIS('POIDS_MAILLES','POIDS',IOCC,1,1,POIDS,ERR)
        WRITE(IFM,*)'  - POIDS_MAILLES :',GRPEMA 
        WRITE(IFM,*)'       AVEC UN POIDS DE : ',POIDS
        WRITE(IFM,*) ' '
        DO 203 IMA=1,NBMA
         MAIL=ZI(RENUM3-1+ZI(RENUM1-1+ZI(IDMA-1+IMA)))
         ZI4(VELO-1+MAIL)=POIDS
 203    CONTINUE
 117  CONTINUE     

C ------- ON IMPRIME LE GRAPH   

      IF ( METH .NE. 'SCOTCH  ') THEN
        IULM1 = ULNUME ()
        IF ( IULM1 .EQ. -1 ) THEN
          CALL UTMESS('F','FETSKP',' ERREUR A L''APPEL DE METIS '//
     &                 'PLUS AUCUNE UNITE LOGIQUE LIBRE !')     
        ENDIF 
        CALL ULOPEN ( IULM1,' ', ' ', 'NEW', 'O' )
        WRITE(IULM1,'(I12,I12,I3)')NBMATO,NBLIEN/2,11
        DO 71 IMA=1,NBMATO
          WRITE(IULM1,'(50I8)')ZI4(VELO-1+IMA),
     &                         (ZI4(CO-1+I),ZI4(EDLO-1+I),
     &                         I=ZI4(IDCO-1+IMA),ZI4(IDCO-1+IMA+1)-1)
 71     CONTINUE     
        CALL ULOPEN (-IULM1,' ',' ',' ',' ')

C CREATION DU FICHIER DU GRAPHE POUR L'APPEL EXTERNE DE SCOTCH
C      ELSE
C
C        IULM1 = ULNUME ()
C        IF ( IULM1 .EQ. -1 ) THEN
C          CALL UTMESS('F','FETSKP',' ERREUR A L''APPEL DE SCOTCH '//
C     &                 'PLUS AUCUNE UNITE LOGIQUE LIBRE !')     
C        ENDIF 
C        CALL ULOPEN ( IULM1,' ', ' ', 'NEW', 'O' )
C        WRITE(IULM1,'(I1)')0
C        WRITE(IULM1,'(I12,I12)')NBMATO,NBLIEN
C        WRITE(IULM1,'(I1,I2,I2)')1,0,11
C        DO 153 IMA=1,NBMATO
C          WRITE(IULM1,'(50I8)')ZI4(VELO-1+IMA),ZI(NBMAMA-1+IMA),
C     &                         (ZI4(EDLO-1+I),ZI4(CO-1+I),
C     &                         I=ZI4(IDCO-1+IMA),ZI4(IDCO-1+IMA+1)-1)
C 153    CONTINUE     
C FIN CREATION DU FICHIER DU GRAPHE POUR SCOTCH

      ENDIF

      CALL JEDETR('&&FETSKP.RENUM1')
      CALL JEDETR('&&FETSKP.NBMAMA')


C ********************************************************************
C                       LANCEMENT DU LOGICIEL

C
C     ************** LANCEMENT DE SCOTCH
C
      IF ( METH .EQ. 'SCOTCH  ') THEN
C CETTE PARTIE PERMET L'APPEL EXTERNE DE SCOTCH - LAISSER EN L'ETAT
C        CALL GETVTX(' ','LOGICIEL' ,0,1,1,REP,ERR)
C        IF ( ERR .NE. 0 ) THEN
C          IULM3 = ULNUME ()
C          CALL ULOPEN ( IULM3,' ', ' ', 'NEW', 'O' )
C          WRITE(KTMP,'(I4)') NBPART
C          CALL LXCADR(KTMP)
C          WRITE(IULM3,'(a,a)')'cmplt '//KTMP
C          WRITE(KTMP2,'(I4)') IULM1
C          CALL LXCADR(KTMP2)
C          WRITE(KTMP3,'(I4)') IULM3
C          CALL LXCADR(KTMP3)
C          IULM2 = ULNUME ()
C          CALL ULOPEN ( IULM2,' ', ' ', 'NEW', 'O' )
C          WRITE(KTMP4,'(I4)') IULM2
C          CALL LXCADR(KTMP4)
C          LREP=0
C          DO 277 I=1,LEN(REP)
C            IF (REP(I:I).NE.' ') LREP=LREP+1
C 277      CONTINUE       
C          JNOM(1)=REP(1:LREP)
C          JNOM(2)='fort.'//KTMP2
C          JNOM(3)='fort.'//KTMP3
C          JNOM(4)='fort.'//KTMP4
C          CALL ULOPEN (-IULM1,' ',' ',' ',' ')
C          CALL ULOPEN (-IULM3,' ',' ',' ',' ')
C          CALL APLEXT(NIV,4,JNOM,ERR)
C        ELSE
C FIN APPEL EXTERNE DE SCOTCH

C         APPEL DE SCOTCH PAR LIBRAIRIE (PASSAGE PAR FETSCO.C)
          CALL WKVECT('&&FETSKP.NMAP','V V S',NBMATO,NMAP)
          IF ( NIV .GE. 2 ) THEN 
            CALL UTTCPU(18,'INIT',6,TMPS)
            CALL UTTCPU(18,'DEBUT',6,TMPS)
          ENDIF
          WRITE(IFM,*) ' '
          WRITE(IFM,*) '***************** SCOTCH *****************'
          WRITE(IFM,*) ' '
          WRITE(IFM,*) ' ' 
          WRITE(IFM,*) ' * LE NOMBRE DE MAILLES    :',NBMATO
          WRITE(IFM,*) ' * LE NOMBRE DE CONNEXIONS :',NBLIEN
          WRITE(IFM,*) ' '
          WRITE(IFM,*) ' '
          CALL FETSCO (NBMATO,NBLIEN,ZI4(CO),ZI4(IDCO),NBPART,ZI4(NMAP),
     &                ZI4(EDLO),ZI4(VELO),ERR)
C           IF ( ERR .NE. 0 ) THEN
C             CALL UTMESS('F','FETSKP','ERREUR DANS '//
C      &                            'L EXECUTION DE SCOTCH')
C           ENDIF
          IF ( NIV .GE. 2 ) THEN
            CALL UTTCPU(18,'FIN',6,TMPS)
            WRITE(IFM,*) ' * TEMPS DE PARTITIONNEMENT  :',TMPS(3)
          ENDIF
          WRITE(IFM,*) '*************** FIN SCOTCH ***************'
          WRITE(IFM,*) ' '
C      ENDIF
C
C     ************** LANCEMENT DE METIS
C
      ELSE 
        WRITE(KTMP,'(I4)') NBPART
        WRITE(KTMP2,'(I4)') IULM1
        CALL LXCADR(KTMP)
        CALL LXCADR(KTMP2)
        JNOM(2)='fort.'//KTMP2
        JNOM(3)=KTMP
        CALL GETVTX(' ','LOGICIEL' ,0,1,1,REP,ERR)
        IF ( ERR .EQ. 0 ) THEN
          CALL REPOUT (1,LREP,REP)
          IF ( METH .EQ. 'PMETIS  ') THEN
            JNOM(1)=REP(1:LREP)//'pmetis'
          ELSEIF ( METH .EQ. 'KMETIS  ') THEN
            JNOM(1)=REP(1:LREP)//'kmetis'
          ENDIF
        ELSE
          LREP=0
          DO 77 I=1,LEN(REP)
            IF (REP(I:I).NE.' ') LREP=LREP+1
 77       CONTINUE       
          JNOM(1)=REP(1:LREP)
        ENDIF
        CALL APLEXT(NIV,3,JNOM,ERR) 
      ENDIF

      CALL JEDETR('&&FETSKP.EDLO')
      CALL JEDETR('&&FETSKP.VELO')


C ********************************************************************
C                    CREATION DES GROUPES DE MAILLES

      SDB=0
      IF ( BORD .EQ. 'OUI     ') THEN
         CALL GETVTX('        ','NOM_GROUP_MA_BORD',0,1,1,SDBORD,ERR)
         IF ( ERR .NE. 0) THEN 
            NBPART=2*NBPART
            SDB=1
         ENDIF   
      ENDIF
         
      CALL WKVECT('&&FETSKP.NUMSDM','V V I',NBMABO,NUMSDM)
      CALL WKVECT('&&FETSKP.NBMASD','V V I',NBPART,NBMASD)

C ------- LECTURE DU RESULTAT DU PARTITONNEUR

      IF ( METH .NE. 'SCOTCH  ') THEN
        IULM2 = ULNUME ()
        IF ( IULM2 .EQ. -1 ) THEN
          CALL UTMESS('F','FETSKP',' ERREUR A L''APPEL DE METIS '//
     &                 'PLUS AUCUNE UNITE LOGIQUE LIBRE !')     
        ENDIF 
        LREP=0
        DO 177 I=1,LEN(KTMP2)
          IF (KTMP2(I:I).NE.' ') LREP=LREP+1
 177    CONTINUE
        JNOM(1)='fort.'//KTMP2(1:LREP)//'.part.'//KTMP
        CALL ULOPEN ( IULM2,JNOM(1),' ', 'OLD', 'O' )
        DO 35 IMA=1,NBMATO  
          READ(IULM2,'(I4)')ZI(NUMSDM-1+ZI(RENUM2-1+IMA))
          ZI(NBMASD+ZI(NUMSDM-1+ZI(RENUM2-1+IMA)))=
     &                     ZI(NBMASD+ZI(NUMSDM-1+ZI(RENUM2-1+IMA)))+1
 35     CONTINUE
        CALL ULOPEN (-IULM2,' ',' ',' ',' ')
      ELSE 
C CETTE PARTIE PERMET L'APPEL EXTERNE DE SCOTCH - LAISSER EN L'ETAT
C        CALL ULOPEN (-IULM2,' ',' ',' ',' ')
C        CALL ULOPEN ( IULM2,'fort.97',' ', 'OLD', 'O' )
C        CALL GETVTX('        ','LOGICIEL' ,0,1,1,REP,ERR)
C        IF ( ERR .NE. 0 ) THEN
C         READ(IULM2,*)NBRE
C         DO 165 IMA=1,NBMATO 
C           READ(IULM2,*)NBRE,ZI(NUMSDM-1+ZI(RENUM2-1+IMA))
C           ZI(NBMASD+ZI(NUMSDM-1+ZI(RENUM2-1+IMA)))=
C     &                     ZI(NBMASD+ZI(NUMSDM-1+ZI(RENUM2-1+IMA)))+1
C 165     CONTINUE                
C          CALL ULOPEN (-IULM2,' ',' ',' ',' ')
C        ELSE
C FIN APPEL EXTERNE DE SCOTCH

         DO 135 IMA=1,NBMATO  
           ZI(NUMSDM-1+ZI(RENUM2-1+IMA))=ZI4(NMAP-1+IMA)
           ZI(NBMASD+ZI(NUMSDM-1+ZI(RENUM2-1+IMA)))=
     &                     ZI(NBMASD+ZI(NUMSDM-1+ZI(RENUM2-1+IMA)))+1
 135     CONTINUE                
         CALL JEDETR('&&FETSKP.NMAP')
C        ENDIF
      ENDIF
      
C ------- ON REMET LES MAILLES DE BORDS 

      IF ( BORD .EQ. 'OUI     ') THEN
         IF ( SDB .EQ. 0) THEN
            DO 55 IMA=1,NBBORD
               MAIL=ZI(RENUM2-1+NBMATO+IMA)
               IF ( ZI(MABORD+ZI(MABORD-1+MAIL)-1) .NE. 0 ) THEN
                  ZI(MABORD-1+MAIL)=ZI(MABORD+ZI(MABORD-1+MAIL)-1)
               ENDIF 
              
               ZI(NUMSDM-1+MAIL)=ZI(NUMSDM-1+ZI(MABORD-1+MAIL))
               ZI(NBMASD+ZI(NUMSDM-1+ZI(MABORD-1+MAIL)))=
     &               ZI(NBMASD+ZI(NUMSDM-1+ZI(MABORD-1+MAIL)))+1
 55         CONTINUE 
         ELSE
            DO 45 IMA=1,NBBORD
               MAIL=ZI(RENUM2-1+NBMATO+IMA)
               IF ( ZI(MABORD+ZI(MABORD-1+MAIL)-1) .NE. 0 ) THEN
                  ZI(MABORD-1+MAIL)=ZI(MABORD+ZI(MABORD-1+MAIL)-1)
               ENDIF 
              
               ZI(NUMSDM-1+MAIL)=ZI(NUMSDM-1+ZI(MABORD-1+MAIL))+NBPART/2
               ZI(NBMASD+NBPART/2+ZI(NUMSDM-1+ZI(MABORD-1+MAIL)))=
     &            ZI(NBMASD+NBPART/2+ZI(NUMSDM-1+ZI(MABORD-1+MAIL)))+1
 45         CONTINUE
         ENDIF
      ENDIF

C ------- VERIFICATION DE LA CONNEXITE

      CALL GETVTX(' ','CORRECTION_CONNEX',0,1,1,VERIF,ERR)
      VAL=0
      IF (VERIF .EQ. 'OUI     ') THEN
        CALL VERICO(NBMATO,NBPART,VAL)
      ENDIF
          
C ------- ON RECONSTRUIT NBMASD 

      IF (VAL .EQ. 1) THEN
        CALL JEDETR('&&FETSKP.NBMASD')
        CALL WKVECT('&&FETSKP.NBMASD','V V I',NBPART,NBMASD)
        DO 145 IMA=1,NBMABO
         ZI(NBMASD+ZI(NUMSDM-1+IMA))=ZI(NBMASD+ZI(NUMSDM-1+IMA))+1
 145    CONTINUE
      ENDIF

C ------- CREATION DES GROUP_MA
      
      NBMATO=NBMABO
      CALL CREAGM(NBMATO,NBPART,SDB,MA,SDBORD,MASD,NOMSDM)

C ------- ON RECUPERE LES TABLEAUX CREES DANS CREAGM

      CALL JEVEUO('&&FETSKP.MASD'  ,'L',MASD  )
      CALL JEVEUO('&&FETSKP.IDMASD','L',IDMASD)
      CALL JEVEUO('&&FETSKP.NOMSDM','L',NOMSDM)

C ------- ON EFFECTUE LE VOISINAGE DE CHAQUE SD 
      
      IF (VAL.EQ.1) THEN 
        CALL WKVECT('&&FETSKP.TEMP','V V I',NBPART,TEMP)
        DO 166 ISD=1,NBPART
          ID=0
          DO 167 IMA=ZI(IDMASD-1+ISD),ZI(IDMASD-1+ISD+1)-1
            IF (ZI(MABORD-1+ZI(MASD-1+IMA)) .NE.0) THEN
              IF ( BORD .EQ. 'OUI     ') GOTO 167
            ENDIF  
            MAIL=ZI(RENUM3-1+ZI(MASD-1+IMA))
            DO 168 I=ZI4(IDCO-1+MAIL),ZI4(IDCO-1+MAIL+1)-1
              MAIL2=ZI4(CO-1+I)    
              IF(ZI(NUMSDM-1+ZI(RENUM2-1+MAIL2)).NE.(ISD-1)) THEN
                DO 169 J=1,ID
                  IF (ZI(TEMP-1+J).EQ.ZI(NUMSDM-1+ZI(RENUM2-1+MAIL2))) 
     &              GOTO 170
 169            CONTINUE
                ZI(TEMP+ID)=ZI(NUMSDM-1+ZI(RENUM2-1+MAIL2))
                ID=ID+1
 170            CONTINUE
              ENDIF
 168        CONTINUE             
 167      CONTINUE
          WRITE(IFM,*)ZK8(NOMSDM-1+ISD),' CONTIENT '
     &                ,ZI(NBMASD-1+ISD),' MAILLES  ET SES VOISINS :'    
     &                ,(ZK8(NOMSDM+ZI(TEMP-1+J)),J=1,ID)
 166    CONTINUE
      ELSE
        DO 56 I=1,NBPART  
            WRITE(IFM,*)'LE SOUS DOMAINE ',ZK8(NOMSDM-1+I),' CONTIENT '
     &                     ,ZI(NBMASD-1+I),' MAILLES '
 56     CONTINUE    
        CALL JEDETR('&&FETSKP.TEMP')
      ENDIF  

      CALL JEDETR('&&FETSKP.RENUM2')
      CALL JEDETR('&&FETSKP.RENUM3')
      CALL JEDETR('&&FETSKP.IDMASD')
      CALL JEDETR('&&FETSKP.NOMSDM')
      CALL JEDETR('&&FETSKP.MASD')
      CALL JEDETR('&&FETSKP.NBMASD')
      CALL JEDETR('&&FETSKP.NUMSDM')
      CALL JEDETR('&&FETSKP.RENUM')
      CALL JEDETR('&&FETSKP.CO')
      CALL JEDETR('&&FETSKP.IDCO')
      CALL JEDETR('&&FETSKP.MABORD')

      CALL JEDEMA()
      END
