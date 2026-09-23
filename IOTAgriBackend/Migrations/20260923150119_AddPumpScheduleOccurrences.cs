using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace IOTAgriBackend.Migrations
{
    /// <inheritdoc />
    public partial class AddPumpScheduleOccurrences : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "PumpScheduleOccurrences",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ScheduleId = table.Column<Guid>(type: "uuid", nullable: false),
                    CommandId = table.Column<Guid>(type: "uuid", nullable: false),
                    OccurrenceUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    DispatchedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PumpScheduleOccurrences", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PumpScheduleOccurrences_PumpSchedules_ScheduleId",
                        column: x => x.ScheduleId,
                        principalTable: "PumpSchedules",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_PumpScheduleOccurrences_CommandId",
                table: "PumpScheduleOccurrences",
                column: "CommandId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_PumpScheduleOccurrences_ScheduleId_OccurrenceUtc",
                table: "PumpScheduleOccurrences",
                columns: new[] { "ScheduleId", "OccurrenceUtc" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PumpScheduleOccurrences");
        }
    }
}
