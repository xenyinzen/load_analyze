/* GDCHART 0.10.0dev  1st CHART SAMPLE  2 Nov 2000 */
/* Copyright Bruce Verderaime 1998-2004 */

/* writes gif file to stdout */

/* sample gdchart usage */
/* this will produce a 3D BAR chart */
/* this is suitable for use as a CGI */

/* for CGI use un-comment the "Content-Type" line */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
 
#include "gdc.h"
#include "gdchart.h"
 

#define MAXNUM	1024
#define MAXFILES	4
#define LEN	4
#define MAXREAD_LEN	64

int usage()
{
        printf("|  \n");
        printf("|  Usage:\n");
        printf("|  \t./do_chart file1 [file2] [file3] [file4]\n");
        printf("|  \n");
        
        return 0;
}

int main(int argc, char** argv)
{
        int i, j, k;
        
        FILE* fp;
        // Pre stored array
        float predata[MAXFILES][MAXNUM] = {0};
        // Array to draw
        float* data = NULL;
        // store header of one colume
        char header[MAXFILES][MAXREAD_LEN];
        // temporarily store the data read from every line
        char str[MAXREAD_LEN];
        // X axis array to draw
        char* x_array[MAXNUM];
        // store the MAX numbers of data in all files
        int N = 0;
        // how many files, up to 4
        int filenum = argc - 1;
        
        if (argc < 2) {
                printf("too few arguments.\n");
                usage();
                exit(-1);
        } 
        
        if (argc > 5) {
                printf("too many arguments.\n");
                usage();
                exit(-1);
        } 
 
        for (k = 0; k < filenum; k++) {
                if ((fp=fopen(argv[k+1], "r")) == NULL) {
                        printf("Can't open the data file.\n");
                        exit(-1);                
                }
                // get the header of every colume in each file
                fgets(header[k], MAXNUM, fp);
                
                i = 0;
                // read data to the array predata from files
                while (fgets(str, MAXNUM, fp)) {
                        predata[k][i] = atof(str);
                        i++;                                
                }
                // get the MAX data line number among all files
                if (N < i)  
                        N = i;
                fclose(fp);
        }
        
        // generate the suitable size of array, gdchart demand.
        data = (float *)malloc(sizeof(float) * N * filenum);                
        for (k=0; k<filenum; k++) {
                for (i=0; i<N; i++) {
                        // copy according to the MAX N.
                        *(data + k*N +i) = predata[k][i];
                }
        }
        
        // format the X axis ticks contents 
        for (j = 0; j<N; j++) {
                x_array[j] = (char *)malloc(sizeof(char)*LEN);
                sprintf(x_array[j], "%d\0", j+1);
        }
        
        // define the colors of every curve
        unsigned long   sc[4]    = { 0xFF8080, 0x00FF20, 0x0000FF, 0x000000 };
        /*
        GDC_ANNOTATION_T anno;
        anno.color = sc[0];
        strncpy(anno.note, "--- Lemote", MAX_NOTE_LEN);
        anno.point = N;
        GDC_annotation_font_size = GDC_LARGE;
        GDC_annotation = &anno;
        */
        GDC_BGColor   = 0xFFFFFFL;                  /* backgound color (white) */
        GDC_LineColor = 0x000000L;                  /* line color      (black) */
        GDC_SetColor  = &(sc[0]);                   /* assign set colors */
    
        GDC_title = header[0];
        GDC_ytitle = "CPU Occ(%)";
        GDC_xtitle = "Time(s)";
        GDC_xaxis_angle = 0;
        GDC_ylabel_fmt = "%0.1f";
        GDC_ylabel_density = 60;

        GDC_image_type = GDC_PNG;
        
        // file to output
        //FILE *outfile = fopen("1.png", "wb");
        
        GDC_out_graph( 800, 500,
                stdout, 			// use stdout as output    
                GDC_LINE,     	
                N,             	
                x_array,        
                filenum,    
                (float*)data, NULL );

        // release the malloc array
        for (j = 0; j<N; j++) {
                free(x_array[j]);
                x_array[j] = NULL;
        }
        free(data);       
        //fclose(outfile);
        return 0;
}
