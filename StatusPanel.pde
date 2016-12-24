/* 
 * File:    StatusPanel.pde
 * Author:  Rishikesh Vaishnav
 * Date:    12/23/2016
 *
 * A modifiable panel on which information can be displayed.
 */
class StatusPanel
{
    /* the dimensions of a status panel */
    public static final double STATUS_PANEL_WIDTH = RAND_MAP_WIDTH + OFFSET * 2;
    public static final double STATUS_PANEL_HEIGHT = 150;

    /* offset of text from edges of panel */
    public static final int TEXT_OFFSET = 5;

    /* color of text */
    public static final int TEXT_COLOR = 0;

    /* the x- and y-position of the panel */
    private double x_pos;
    private double y_pos;

    /* the total distance traveled */
    private double total_distance = 0;

    /* instructional notes to be printed on the panel */
    private String notes = 
        "Controls:"
        + "\nr - restart; n - randomize and restart;"
        + "\np - toggle show pheromone trails;"
        + " a - toggle show best-so-far ACO tour (green);"
        + "\ng - toggle show best greedy algorithm tour (blue);";

    /* the map this panel uses */
    private Map map;

    /** 
     * Sets up this panel at a specified location.
     *
     * @param init_x_pos the initial x-position of this panel
     * @param init_y_pos the initial y-position of this panel
     * @param init_map the map this panel uses
     */
    public StatusPanel ( double init_x_pos, double init_y_pos, Map init_map )
    {
        /* set the initial position of this panel */
        this.x_pos = init_x_pos;
        this.y_pos = init_y_pos;

        /* set the map */
        this.map = init_map;
    }

    /**
     * Redraws this panel.
     */
    public void update ()
    {
        /* set color */
        fill( BACKGROUND_COLOR );

        /* draw the panel */
        rect( ( float ) x_pos, ( float ) y_pos, 
            ( float ) STATUS_PANEL_WIDTH, ( float ) STATUS_PANEL_HEIGHT );

        /* set text color and size */
        fill( TEXT_COLOR );
        textSize( TEXT_SIZE );

        /* draw text */
        text( "Length of best greedy tour: \n" + map.getGreedyLength()
               + "\nLength of best-so-far ACO tour: \n" + map.getACOLength()
               + "\n" + notes, 
            ( float ) ( x_pos + TEXT_OFFSET ),
            ( float ) ( y_pos + TEXT_OFFSET ),
            ( float ) ( STATUS_PANEL_WIDTH - ( TEXT_OFFSET * 2 ) ),
            ( float ) ( STATUS_PANEL_HEIGHT ) );
    }

    /**
     * Resets the total distance.
     *
     * @param new_total_distance the new total distance
     */
    public void set_total_distance ( double new_total_distance )
    {
        total_distance = new_total_distance;
    }
}
